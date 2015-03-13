# Records a “version” (or “edit”) of a given “versionable” item.
# Versionable items must have a `has_many :versions, as: :item` relation,
# and they are responsible for generating their own Version records.
class Version < ActiveRecord::Base
  acts_as_authority_controlled authority_area: 'Content', inherits_from: :item
  attr_accessible :user, :edited_at, :edit_comment, :filename, :title, :values

  belongs_to :item, polymorphic: true
  belongs_to :user

  validates_presence_of :item
  validates_presence_of :user
  validates_presence_of :edited_at

  default_scope { order(:edited_at, :id) }
  scope :versions_before, lambda { |before_datetime| where('versions.edited_at < ?', before_datetime) }
  scope :versions_after, lambda { |after_datetime| where('versions.edited_at > ?', after_datetime) }

  # Get the most recent version that preceded this one.
  def previous
    @previous ||= item.versions.versions_before(self.edited_at).last
  end

  # Get the most recent version of this version’s item.
  def current
    item.versions.last
  end

  # Is this version the most recent version?
  def is_current?
    current == self
  end

  # Assumptions:
  # * version is a version on the same type of item model as self
  def diff_with(version)
    diff = {}
    diff['filename'] = version.filename unless filename == version.filename
    diff['title'] = version.title unless title == version.title
    keys = (values.keys + version.values.keys).uniq
    keys.each do |key|
      value = (values[key.to_s] || values[key.to_sym]).to_s
      version_value = (version.values[key.to_s] || version.values[key.to_sym]).to_s
      diff[key] = version_value unless value == version_value
    end
    diff
  end

end
