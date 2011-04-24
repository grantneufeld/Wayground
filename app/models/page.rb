# encoding: utf-8

# Web pages.
class Page < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Content'
  attr_accessor :editor, :edit_comment
  attr_accessible :filename, :title, :description, :content, :edit_comment

  belongs_to :parent, :class_name => 'Page'
  has_many :pages, :as => :parent
  has_one :path, :as => :item, :validate => true, :dependent => :destroy
  has_many :versions, :as => :item, :dependent => :delete_all

  before_create :generate_path
  before_update :update_path
  after_save :add_version

  validates_length_of :filename, :within => 1..127
  validates_format_of :filename,
    :with=>/\A(\/|([\w_~\+\-]+)(\.[\w_]+)?\/?)\z/,
    :message=>'must only be letters, numbers, dashes and underscores, with an optional extension; e.g., “a-filename_1.txt”'
  validates_presence_of :title

  def generate_path
    if self.path.nil?
      self.path = Path.new(:sitepath => self.calculate_sitepath)
      self.path.item = self
    end
  end

  def update_path
    self.path.update_attributes!(:sitepath => self.calculate_sitepath)
  end

  def calculate_sitepath
    "#{(parent ? parent.sitepath : '')}/#{self.filename}".gsub(/\/\/+/, '/')
  end

  # Add a Version based on the current state of this item
  def add_version
    self.versions.create!(:user => editor, :edited_at => self.updated_at, :edit_comment => edit_comment,
      :filename => filename, :title => title, :description => description,
      :content => content, :content_type => 'text/html'
    )
  end

  def breadcrumbs
    if parent
      parent.breadcrumbs << {:text => parent.title, :url => parent.sitepath}
    else
      []
    end
  end

  def sitepath
    path.sitepath
  end

end
