class CreateVersions < ActiveRecord::Migration
  def self.up
    create_table :versions do |t|
      t.belongs_to :item, :polymorphic => true, :null => false
      t.belongs_to :user, :null => false
      t.datetime :edited_at, :null => false
      t.string :edit_comment
      t.string :filename
      t.string :title
      t.text :url
      t.text :description
      t.text :content
      t.string :content_type
      t.date :start_on
      t.date :end_on
    end
    change_table :versions do |t|
      t.index [:item_type, :item_id, :edited_at], :name=>'item_by_date'
      t.index [:edited_at, :item_type, :item_id], :name=>'edits_by_date'
      t.index [:user_id, :item_type, :item_id, :edited_at], :name=>'user_by_item'
      t.index [:user_id, :edited_at, :item_type, :item_id], :name=>'user_by_date'
    end
  end

  def self.down
    drop_table :versions
  end
end
