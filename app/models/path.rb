# encoding: utf-8

# Defines custom URLs (“paths”) for arbitrary items on the site,
# or to redirect local URLs to other local paths or to remote URLs.
class Path < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Content', :inherits_from => :item
	attr_accessible :sitepath, :redirect

  belongs_to :item, :polymorphic => true

  before_validation :clean_sitepath

  validates_format_of :sitepath,
    :with=>/\A\/(([\w%_~\+\-]+\/?)+(\.[\w%_\-]+|\/)?)?\z/,
    :message => 'must begin with a ‘/’ and be letters, numbers, dashes, percentage signs, underscores and/or slashes, with an optional extension'
  validates_uniqueness_of :sitepath
  validates_presence_of :redirect,
    :if=>Proc.new {|path| (path.item.nil? && path.item_id.nil?)},
    :message => 'must have a redirect url/path if not attached to an item on the website'
  validates_format_of :redirect, :allow_nil => true,
    :with => /\A(https?:\/\/.+|\/(([\w%~_\?=&\-]+\/?)+(\.[\w%~_\?=&#\-]+|\/)?)?)\z/,
    :message => 'must begin with a valid URL (including ‘http://’) or a valid root-relative sitepath (starts with a slash ‘/’)'

  scope :for_sitepath, lambda {|searchpath|
    # strip trailing slash, if present
    matches = searchpath.match(/^(.+)\/$/)
    where({:sitepath => (matches ? matches[1] : searchpath)})
  }
  scope :in_order, order(:sitepath)

  def self.home
    self.where(:sitepath => '/').first
  end

  def self.find_for_path(inpath)
    inpath = "/#{inpath}" unless inpath[0].chr == '/'
    self.for_sitepath(inpath).first
  end

  # The sitepath should not end in a slash, except for the root/home path.
  def clean_sitepath
    matches = self.sitepath.match /^(.+)\/$/
    self.sitepath = matches[1] if matches
  end

end
