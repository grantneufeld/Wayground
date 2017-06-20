# Define a path (relative url) to an item.
class CreatePaths < ActiveRecord::Migration[5.1]
  def self.up
    create_table :paths do |t|
      t.belongs_to :item, polymorphic: true
      t.text :sitepath, null: false
      t.text :redirect
      t.timestamps
    end
    # for MySQL because it can’t deal with indexing text columns
    # unless a constraint is explicitly defined
    if connection.class.name =~ /.*MySQL.*/i
      say 'creating paths.sitepath index for MySQL'
      execute 'ALTER TABLE paths ADD UNIQUE (sitepath(255));'
    end
    change_table :paths do |t|
      t.index [:sitepath], name: 'sitepath', unique: true unless connection.class.name =~ /.*MySQL.*/i
      t.index %i(item_type item_id), name: 'item_idx'
    end
  end

  def self.down
    drop_table :paths
  end
end
