class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.belongs_to :container_item, :polymorphic => true
      t.belongs_to :datastore
      t.string :processor, :limit => 31, :null => false
      t.string :url, :limit => 511, :null => false
      t.string :method, :limit => 7, :null => false, :default => 'get'
      t.string :post_args, :limit => 1023
      t.datetime :last_updated_at
      t.datetime :refresh_after_at
      t.string :title, :limit => 127
      t.string :description, :limit => 511
      t.text :options
      t.timestamps
    end
    add_index :sources, [:container_item_type, :container_item_id], :name => 'container'
    add_index :sources, [:processor]
    add_index :sources, [:last_updated_at]
    add_index :sources, [:refresh_after_at]
  end
end
