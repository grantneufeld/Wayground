# encoding: utf-8

# Records a “version” (or “edit”) of a given “versionable” item.
# Versionable items must have a “has_many :versions, :as => :item” relation,
# and they are responsible for generating their own Version records.
class Version < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Content', :inherits_from => :item

  belongs_to :item, :polymorphic => true
  belongs_to :user

  validates_presence_of :item
  validates_presence_of :user
  validates_presence_of :edited_at

  default_scope order(:edited_at, :id)
  scope :versions_before, lambda {|before_datetime| where('versions.edited_at < ?', before_datetime) }
  scope :versions_after, lambda {|after_datetime| where('versions.edited_at > ?', after_datetime) }
  scope :current_versions, group(:item_type, :item_id)

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

end
