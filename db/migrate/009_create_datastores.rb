class CreateDatastores < ActiveRecord::Migration
  def self.up
    create_table :datastores do |t|
      t.belongs_to :document
      t.binary :data, :null => false, :limit => 31.megabytes
    end
    change_table :datastores do |t|
      t.index [:document_id], :name=>'document_id'
    end
  end

  def self.down
    drop_table :datastores
  end
end
