class CreateAuthorities < ActiveRecord::Migration
  def self.up
    create_table :authorities do |t|
      t.belongs_to :user
      t.belongs_to :item, :polymorphic => true
      t.string :area, :limit => 31
      t.boolean :is_owner
      t.boolean :can_create
      t.boolean :can_view
      t.boolean :can_edit
      t.boolean :can_delete
      t.boolean :can_invite
      t.boolean :can_permit
      t.timestamps
    end
    change_table :authorities do |t|
      t.index [:user_id, :item_id, :item_type, :area], :name=>'user_map', :unique=>true
      t.index [:item_id, :item_type, :user_id], :name=>'item'
      t.index [:area, :user_id], :name=>'area'
    end
  end

  def self.down
    drop_table :authorities
  end
end
