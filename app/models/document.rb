# encoding: utf-8

# Storage of a data file.
# Note that the data table is currently set to restrict files to 31 megabytes in size.
class Document < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Content'
  attr_accessible :file, :custom_filename, :description, :is_authority_controlled

  # The user who uploaded the document. May be nil if the system generated the document.
  belongs_to :user
  # The optional Path that contains this document. If absent, document is at “/filename”.
  belongs_to :container_path, :class_name => "Path", :foreign_key => "path_id"
  # The Path object that lets the document be accessed via a sitepath (such as “/somestuff/filename”).
  # Will be nil if the document does not have a container_path.
  has_one :path, :as => :item, :validate => true, :dependent => :destroy
  # the actual data of the file is stored in a separate table
  has_one :datastore

  before_save :determine_size
  before_save :generate_path
  before_update :update_path

  # TODO: use a helper/module to specify filename validations since the same validations occur across multiple models
  validates_length_of :filename, :within => 1..127
  validates_format_of :filename,
    :with=>/\A(\/|([\w_~\+\-]+)(\.[\w_]+)?\/?)\z/,
    :message=>'must only be letters, numbers, dashes and underscores, with an optional extension; e.g., “a-filename_1.txt”'
  validates_presence_of :content_type
  validates_format_of :content_type, :with => /^[a-z\-]+\/[a-z\+\-]+$/,
    :message => "is not a valid content type"
  # require data to be set, but allow it to be empty
  validates_presence_of :data, :unless => Proc.new {|doc| doc.data == ''}

  # TODO: try to figure out a way to genericize the for_user scope so it can come from the authority_controlled library instead
  scope :for_user, lambda { |user|
    if user.nil?
      # if anonymous user, don’t allow any authority controlled documents
      where(:is_authority_controlled => false)
    elsif user.has_authority_for_area(authority_area)
      # if user has admin view authority on the Content area, allow all documents
    else
      # need to check if user has authority for non-public documents
      # allow non-authority controlled documents, and documents the user has authority for
      self.
        joins(sanitize_sql_array([
          # check against the authorities table
          "LEFT OUTER JOIN authorities " +
          # match the authorities for the documents
          "ON authorities.item_type = 'Document' AND authorities.item_id = documents.id " +
          # match authorities for the specified user
          "AND authorities.user_id = ?",
          user.id
        ])).
        where([
          # show public, not authority-controlled, documents
          "documents.is_authority_controlled = ? " +
          # and documents posted by the user
          "OR documents.user_id = ? " +
          # and documents that have an appropriate matching authority for the user
          "OR (authorities.is_owner = ? OR authorities.can_view = ?)",
          false, user.id, true, true
        ])
    end
  }

  def determine_size
    self.size = (data.nil? ? 0 : data.size)
  end

  def generate_path(sitepath = nil)
    if container_path.present? && path.nil?
      self.path = Path.new(:sitepath => (sitepath || calculate_sitepath))
      path.item = self
    end
  end

  def update_path
    sitepath = calculate_sitepath
    if sitepath.nil?
      if path
        path.destroy
        self.path = nil
      end
    elsif path
      path.update_attributes!(:sitepath => sitepath)
    else
      generate_path(sitepath)
      path.save!
    end
  end

  def calculate_sitepath
    if container_path
      "#{container_path.sitepath}/#{self.filename}".gsub(/\/\/+/, '/')
    else
      nil
    end
  end

  def sitepath
    if path
      path.sitepath
    else
      nil
    end
  end

  def file=(file)
    return unless file.is_a?(ActionDispatch::Http::UploadedFile) || file.is_a?(File)
    if filename.blank?
      self.filename = file.original_filename rescue file.path.match(/([^\/]+)$/)[1]
      cleanup_filename
    end
    if content_type.blank?
      self.content_type = file.content_type rescue 'application/data'
    end
    self.data = file.read
  end

  # Replaces or removes any disallowed characters from the filename.
  def cleanup_filename
    # Convert spaces to underscores,
    self.filename.gsub!(' ', '_')
    # em and en dashes to plain dashes,
    self.filename.gsub!(/[–—]/, '-')
    # convert accented characters to ascii equivalents,
    self.filename.gsub!(/àáäâãÀÁÄÂÃåÅ/, 'a')
    self.filename.gsub!(/èéëêÈÉËÊ/, 'e')
    self.filename.gsub!(/ìíïîÌÍÏÎ/, 'i')
    self.filename.gsub!(/òóöôõÒÓÖÔÕøØ/, 'o')
    self.filename.gsub!(/ùúüûÙÚÛÛ/, 'u')
    self.filename.gsub!(/ç¢/, 'c')
    self.filename.gsub!(/ƒ/, 'f')
    self.filename.gsub!(/ñÑ/, 'n')
    # and then remove all forbidden characters.
    self.filename.gsub!(/[^A-Za-z0-9_\.\-]+/, '')
  end

  def custom_filename=(custom)
    unless custom.blank?
      self.filename = custom
    end
  end
  def custom_filename
    nil
  end

  def data
    if datastore
      datastore.data
    else
      nil
    end
  end
  def data=(data)
    self.datastore ||= Datastore.new()
    self.datastore.data = data
  end

  # Set the response headers for when this document is to be the content/body of the HTTP response.
  def assign_headers(response)
    # Content-Length is auto-set
    response.headers.merge!({
      'Last-Modified' => (updated_at || created_at).to_s(:http_header),
      'Content-Type' => content_type
    })
    # set Cache-control to “private/public, max-age=?, no-transform” where max-age is in seconds
    cache_params = {:extras => ['no-transform']}
    if is_authority_restricted?
      cache_params = {:max_age => 30.minutes, :public => false}
    else
      cache_params = {:max_age => 1.day, :public => true}
    end
    response.cache_control.merge!(cache_params.merge!(:extras => ['no-transform']))
  end
end
