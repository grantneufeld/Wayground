# encoding: utf-8

# Used to store data files
class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.belongs_to :user
      t.belongs_to :path
      t.boolean :is_authority_controlled, :null => false, :default => false
      t.string :filename, :null => false, :limit => 127
      t.integer :size, :null => false
      t.string :content_type, :null => false # mimetype
      t.string :charset, :limit => 31 # just for text formats to specify the encoding such as ASCII, UTF-8,…
      t.string :description, :limit => 1023
      t.binary :data, :null => false, :limit => 31.megabytes
      t.timestamps
    end
    change_table :documents do |t|
      t.index [:user_id, :filename], :name=>'userfile'
      t.index [:path_id, :filename], :name=>'pathname', :unique => true
      t.index [:filename], :name=>'file'
    end
  end

  def self.down
    drop_table :documents
  end
end
