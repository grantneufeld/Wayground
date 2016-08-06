# Used to store the metadata for a data file.
class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.belongs_to :datastore # the actual data of the file
      t.belongs_to :container_path # optional Path containing this document (sitepath = '/container/filename')
      t.belongs_to :user
      t.boolean :is_authority_controlled, null: false, default: false
      t.string :filename, null: false, limit: 127
      t.integer :size, null: false
      t.string :content_type, null: false # mimetype
      t.string :charset, limit: 31 # just for text formats to specify the encoding such as ASCII, UTF-8,…
      t.string :description, limit: 1023
      t.timestamps
    end
    change_table :documents do |t|
      t.index [:datastore_id], name: 'data'
      t.index %i(user_id filename), name: 'userfile'
      t.index %i(container_path_id filename), name: 'pathname', unique: true
      t.index [:filename], name: 'file'
    end
  end

  def self.down
    drop_table :documents
  end
end
