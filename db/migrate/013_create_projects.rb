class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.belongs_to :parent # Project that this Project is a subproject of
      t.belongs_to :creator, :null => false # User who created the Project
      t.belongs_to :owner, :null => false # User who has admin control of the Project
      t.boolean :is_visible, :null => false, :default => false # project shows up in lists and searches
      t.boolean :is_public_content, :null => false, :default => false # anyone can see the project content
      t.boolean :is_visible_member_list, :null => false, :default => false # anyone can see the member list
      t.boolean :is_joinable, :null => false, :default => false # people can join without admin permission
      t.boolean :is_members_can_invite, :null => false, :default => false # members can invite other users
      t.boolean :is_not_unsubscribable, :null => false, :default => false # members can’t remove themselves
      t.boolean :is_moderated, :null => false, :default => false # member posts are pre-screened
      t.boolean :is_only_admin_posts, :null => false, :default => false # only admins can post
      t.boolean :is_no_comments, :null => false, :default => false # no comments can be made on project content
      t.string :filename
      t.string :name, :null => false
      t.text :description
      t.timestamps
    end
    change_table :projects do |t|
      t.index [:parent_id], :name => 'parent'
      t.index [:creator_id], :name=>'creator'
      t.index [:owner_id], :name=>'owner'
      t.index [:filename]
      t.index [:name, :is_visible]
    end
  end

  def self.down
    drop_table :projects
  end
end
