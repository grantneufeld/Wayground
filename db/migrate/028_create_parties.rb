class CreateParties < ActiveRecord::Migration
  def self.up
    create_table :parties do |t|
      t.belongs_to :level, null: false
      t.string :filename, null: false
      t.string :name, null: false
      #t.string :aliases, array: true
      t.string :abbrev, null: false
      t.boolean :is_registered, null: false, default: false
      t.string :colour
      t.string :url
      t.text :description
      t.date :established_on
      t.date :registered_on
      t.date :ended_on
      t.timestamps
    end
    execute 'ALTER TABLE parties ADD COLUMN aliases text[]'
    add_index :parties, [:level_id, :filename], unique: true
    add_index :parties, [:level_id, :name], unique: true
    add_index :parties, [:level_id, :abbrev], unique: true
  end

  def self.down
    drop_table :parties
  end
end
