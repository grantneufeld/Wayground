# Storage of raw file data.
class CreateDatastores < ActiveRecord::Migration
  def self.up
    create_table :datastores do |t|
      t.binary :data, null: false, limit: 127.megabytes
    end
  end

  def self.down
    drop_table :datastores
  end
end
