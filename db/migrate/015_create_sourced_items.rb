# Remember the source for a given item.
class CreateSourcedItems < ActiveRecord::Migration[5.1]
  def change
    create_table :sourced_items do |t|
      t.belongs_to :source, null: false
      t.belongs_to :item, polymorphic: true, null: false
      t.belongs_to :datastore
      t.string :source_identifier
      t.datetime :last_sourced_at, null: false
      t.boolean :has_local_modifications, default: false, null: false
      t.timestamps
    end
    add_index :sourced_items, :source_identifier
  end
end
