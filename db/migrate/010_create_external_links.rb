class CreateExternalLinks < ActiveRecord::Migration
  def self.up
    create_table :external_links do |t|
      t.belongs_to :item, :null => false, :polymorphic => true
      t.boolean :is_source, :null => false, :default => false
      t.integer :position, :default => nil
      t.string :site, :limit => 31
      t.string :title, :null => false, :limit => 255
      t.text :url, :null => false, :limit => 1023
      t.timestamps
    end
    change_table :external_links do |t|
      t.index [:item_type, :item_id, :position]
      t.index [:site], :name=>'site'
      t.index [:title], :name=>'title'
    end
  end

  def self.down
    drop_table :external_links
  end
end
