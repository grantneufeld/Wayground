# encoding: utf-8

# Defines custom URLs (“paths”) for arbitrary items on the site,
# or to redirect local URLs to other local paths or to remote URLs.
class Path < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Content', :inherits_from => :item
  attr_accessible :sitepath, :redirect

  belongs_to :item, :polymorphic => true

  before_validation :clean_sitepath, :clean_redirect

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
    matches = searchpath.match(/\A(.+)\/\z/)
    where({:sitepath => (matches ? matches[1] : searchpath)})
  }
  scope :in_order, -> { order(:sitepath) }
  scope :for_user, lambda { |user|
    # this is going to get ugly...
    # Basically, going to need a join for each type of model that uses paths.
    # Will also have to add a line to each of the where clauses, too.
    # And extend the authorities table join.
    # Sigh.
    if user.nil?
      # if anonymous user, don’t allow any authority controlled items
      self.
        joins(
          # use parent item for linking to authorities
          "LEFT OUTER JOIN pages " +
          # match the parent item for the item
          "ON paths.item_type = 'Page' AND pages.id = paths.item_id "
        ).
        where("pages.is_authority_controlled = ? OR paths.item_type IS NULL", false)
    elsif user.has_authority_for_area(authority_area)
      # if user has admin view authority on the Content area, allow all documents
    else
      # need to check if user has authority for non-public documents
      # allow non-authority controlled documents, and documents the user has authority for
      self.
        joins(
          # use parent item for linking to authorities
          "LEFT OUTER JOIN pages " +
          # match the parent item for the item
          "ON paths.item_type = 'Page' AND pages.id = paths.item_id "
        ).
        joins(sanitize_sql_array([
          # check against the authorities table
          "LEFT OUTER JOIN authorities " +
          # match the authorities for the parent item
          "ON authorities.item_type = 'Page' AND authorities.item_id = pages.id " +
          # match authorities for the specified user
          "AND authorities.user_id = ?",
          user.id
        ])).
        where([
          # show all items without a parent item
          "paths.item_id IS NULL " +
          # show public, not authority-controlled, items
          "OR pages.is_authority_controlled = ? " +
          # and items that have an appropriate matching authority for the user
          "OR (authorities.is_owner = ? OR authorities.can_view = ?)",
          false, true, true
        ])
    end
  }

  def self.home
    self.where(:sitepath => '/').first
  end

  def self.find_for_path(inpath)
    inpath = "/#{inpath}" unless inpath[0].chr == '/'
    self.for_sitepath(inpath).first
  end

  # The sitepath should not end in a slash, except for the root/home path.
  def clean_sitepath
    matches = self.sitepath.match /\A(.+)\/\z/
    self.sitepath = matches[1] if matches
  end

  # Clear any leading or trailing whitespace from the redirect.
  def clean_redirect
    self.redirect = redirect.strip if redirect?
  end

end
