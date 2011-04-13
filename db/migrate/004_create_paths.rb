class CreatePaths < ActiveRecord::Migration
  def self.up
    create_table :paths do |t|
      t.belongs_to :item, :polymorphic => true
      t.text :sitepath, :null=>false
      t.text :redirect
      t.timestamps
    end
    # for MySQL because it can’t deal with indexing text columns
    # unless a constraint is explicitly defined
    if connection.class.name.match /.*MySQL.*/i
      say "creating paths.sitepath index for MySQL"
      execute 'ALTER TABLE paths ADD UNIQUE (sitepath(255));'
    end
    change_table :paths do |t|
      unless connection.class.name.match /.*MySQL.*/i
        t.index [:sitepath], :name=>'sitepath', :unique=>true
      end
      t.index [:item_type, :item_id], :name=>'item_idx'
    end
  end

  def self.down
    drop_table :paths
  end
end
