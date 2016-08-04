# Metadata for a data file. (The actual file data is kept in Datastore.)
class Document < ApplicationRecord
  acts_as_authority_controlled :authority_area => 'Content'

  # the actual data of the file is stored in a separate table
  belongs_to :datastore
  # The user who uploaded the document. May be nil if the system generated the document.
  belongs_to :user
  # The optional Path that contains this document.
  belongs_to :container_path, :class_name => "Path"
  # The Path object that lets the document be accessed via a sitepath (such as “/somestuff/filename”).
  # Will be nil if the document does not have a container_path.
  has_one :path, :as => :item, :validate => true, :dependent => :destroy

  before_save :determine_size
  before_save :generate_path
  before_update :update_path

  # TODO: create a validator class for filenames with extensions
  validates_length_of :filename, :within => 1..127
  validates_format_of :filename,
    with: /\A(\/|([\w_~\+\-]+)(\.[\w_]+)?\/?)\z/,
    message: (
      'must only be letters, numbers, dashes and underscores, with an optional extension;' +
      ' e.g., “a-filename_1.txt”'
    )
  validates_presence_of :content_type
  validates_format_of :content_type, :with => /\A[a-z\-]+\/[a-z\+\-]+\z/,
    :message => "is not a valid content type"
  # require data to be set, but allow it to be empty
  validates_presence_of :datastore, unless: Proc.new { |doc| doc.data == '' }

  # TODO: genericize the for_user scope so it can come from the authority_controlled library instead
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
    self.size = (data ? data.size : 0)
  end

  def generate_path(sitepath = nil)
    if container_path.present? && !path
      self.path = Path.new(:sitepath => (sitepath || calculate_sitepath))
      path.item = self
    end
  end

  def update_path
    sitepath = calculate_sitepath
    if !sitepath
      if path
        path.destroy
        self.path = nil
      end
    elsif path
      path.update!(sitepath: sitepath)
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
    return if file.blank? || file.is_a?(String)
    if filename.blank?
      self.filename = file.original_filename rescue file.path.match(/([^\/]+)\z/)[1]
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
    self.filename.gsub!(/ +/, '_')
    # em and en dashes to plain dashes,
    self.filename.gsub!(/[–—]/, '-')
    # convert accented characters to ascii equivalents,
    self.filename.gsub!(/[ªáÁàÀâÂåÅäÄãÃ]/, 'a')
    self.filename.gsub!(/[èéëêÈÉËÊ]/, 'e')
    self.filename.gsub!(/[ìíïîÌÍÏÎ]/, 'i')
    self.filename.gsub!(/[òóöôõÒÓÖÔÕøØº]/, 'o')
    self.filename.gsub!(/[ùúüûÙÚÛµ]/, 'u')
    self.filename.gsub!(/[æÆ]/, 'ae')
    self.filename.gsub!(/[œŒ]/, 'oe')
    self.filename.gsub!(/[ç¢]/, 'c')
    self.filename.gsub!(/[ƒ]/, 'f')
    self.filename.gsub!(/[ﬁ]/, 'fi')
    self.filename.gsub!(/[ﬂ]/, 'fl')
    self.filename.gsub!(/[ñÑ]/, 'n')
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
      'Last-Modified' => (updated_at || created_at).utc.to_s(:http_header),
      'Content-Type' => content_type
    })
    # set Cache-control to “private/public, max-age=?, no-transform” where max-age is in seconds
    if is_authority_restricted?
      cache_params = { max_age: 30.minutes, public: false }
    else
      cache_params = { max_age: 1.day, public: true }
    end
    response.cache_control.merge!(cache_params.merge!(:extras => ['no-transform']))
  end
end
