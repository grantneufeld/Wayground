class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      t.belongs_to :user
      t.belongs_to :submitter
      t.string :filename, null: false
      t.string :fullname, null: false
      #t.string :aliases, array: true
      t.text :bio
      t.timestamps
    end
    execute 'ALTER TABLE people ADD COLUMN aliases text[]'
    add_index :people, :user_id, unique: true # only one person record can be associated with a user
    add_index :people, :submitter_id
    add_index :people, :filename, unique: true
    add_index :people, :fullname
    add_index :people, :aliases
  end

  def self.down
    drop_table :people
  end
end
