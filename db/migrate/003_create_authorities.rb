# Define a permission(s) for a User for an area or specific item.
class CreateAuthorities < ActiveRecord::Migration[5.1]
  def self.up
    create_table :authorities do |t|
      t.belongs_to :user
      t.belongs_to :authorized_by
      t.belongs_to :item, polymorphic: true
      t.string :area, limit: 31
      t.boolean :is_owner
      t.boolean :can_create
      t.boolean :can_view
      t.boolean :can_update
      t.boolean :can_delete
      t.boolean :can_invite
      t.boolean :can_permit
      t.boolean :can_approve
      t.timestamps
    end
    change_table :authorities do |t|
      t.index %i(user_id item_id item_type area), name: 'user_map', unique: true
      t.index %i(authorized_by_id user_id area), name: 'authorizer'
      t.index %i(item_id item_type user_id), name: 'item'
      t.index %i(area user_id), name: 'area'
    end
  end

  def self.down
    drop_table :authorities
  end
end
