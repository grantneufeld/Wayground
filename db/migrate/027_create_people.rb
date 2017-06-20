# A person. May have multiple candidacies in elections. May hold multiple offices.
class CreatePeople < ActiveRecord::Migration[5.1]
  def self.up
    create_table :people do |t|
      # a user record can only be associated with one person
      t.belongs_to :user, index: { unique: true }
      t.belongs_to :submitter
      t.string :filename, null: false
      t.string :fullname, null: false
      t.string :aliases, array: true, null: false, default: '{}'
      t.text :bio
      t.timestamps
    end
    # execute 'ALTER TABLE people ADD COLUMN aliases text[]'
    add_index :people, :filename, unique: true
    add_index :people, :fullname
    add_index :people, :aliases
  end

  def self.down
    drop_table :people
  end
end
