# for storage of system/site-wide settings
class CreateSettings < ActiveRecord::Migration
  def self.up
    create_table :settings do |t|
      t.string :key
      t.text :value
      t.timestamps
    end
    change_table :settings do |t|
      t.index [:key], :name=>'key', :unique=>true
    end
  end

  def self.down
    drop_table :settings
  end
end
