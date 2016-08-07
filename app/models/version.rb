# Records a “version” (or “edit”) of a given “versionable” item.
# Versionable items must have a `has_many :versions, as: :item` relation,
# and they are responsible for generating their own Version records.
class Version < ApplicationRecord
  acts_as_authority_controlled authority_area: 'Content', inherits_from: :item

  belongs_to :item, polymorphic: true
  belongs_to :user

  validates :item, presence: true
  validates :user, presence: true
  validates :edited_at, presence: true

  default_scope { order(:edited_at, :id) }
  scope :versions_before, ->(before_datetime) { where('versions.edited_at < ?', before_datetime) }
  scope :versions_after, ->(after_datetime) { where('versions.edited_at > ?', after_datetime) }

  # Get the most recent version that preceded this one.
  def previous
    @previous ||= item.versions.versions_before(edited_at).last
  end

  # Get the most recent version of this version’s item.
  def current
    item.versions.last
  end

  # Is this version the most recent version?
  def current?
    current == self
  end

  # Assumptions:
  # * version is a version on the same type of item model as self
  def diff_with(version)
    diff = diff_attrs(version)
    keys = (values.keys + version.values.keys).uniq
    keys.each do |key|
      value = value_at_key_string(values, key)
      version_value = value_at_key_string(version.values, key)
      diff[key] = version_value unless value == version_value
    end
    diff
  end

  private

  def diff_attrs(version)
    diff = {}
    diff['filename'] = version.filename unless filename == version.filename
    diff['title'] = version.title unless title == version.title
    diff
  end

  def value_at_key_string(values_to_check, key)
    (values_to_check[key.to_s] || values_to_check[key.to_sym]).to_s
  end
end
