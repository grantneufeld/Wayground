# encoding: utf-8

# A grouping of Memberships (typically Users or EmailAddresses),
# and various items (Events, Pages, Tasks, etc.).
class Project < ActiveRecord::Base
  acts_as_authority_controlled :authority_area => 'Projects', :item_authority_flag_field => :always_viewable
  attr_accessible(
    :is_visible, :is_public_content, :is_visible_member_list, :is_joinable,
    :is_members_can_invite, :is_not_unsubscribable, :is_moderated, :is_only_admin_posts,
    :is_no_comments, :name, :filename, :description #, :editor, :edit_comment
  )

  # The optional parent Project of this Project. The Project is a sub-project if it has a parent.
  belongs_to :parent, :class_name => "Project"
  # The User who originally created the Project. Never changes.
  belongs_to :creator, :class_name => "User"
  # The current owner of the Project.
  belongs_to :owner, :class_name => "User"

  validates_presence_of :creator_id
  validates_presence_of :owner_id
  validates_presence_of :name
  validates_length_of :filename, :within => 0..127, :allow_nil => true
  validates_format_of :filename,
    :with => /\A([\w_\-]*)\z/,
    :allow_nil => true,
    :message => 'must only be letters, numbers, dashes and underscores, with no extension; e.g., “a-filename_1”'
  validates_uniqueness_of :filename, :allow_blank => true

  default_scope order('name')

end
