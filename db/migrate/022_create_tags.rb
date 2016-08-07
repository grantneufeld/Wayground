# Tags (folksonomy, categories, keywords, etc.)
class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.belongs_to :item, null: false, polymorphic: true
      t.belongs_to :user
      t.string :tag, null: false
      t.string :title
      t.boolean :is_meta, null: false, default: false
      t.timestamps
    end
    add_index :tags, %i(item_type item_id tag), name: 'tags_item_tag_idx', unique: true
    add_index :tags, %i(user_id item_type item_id), name: 'tags_user_item_idx'
    add_index :tags, %i(tag item_type item_id), name: 'tags_tag_item_idx'
  end
end
