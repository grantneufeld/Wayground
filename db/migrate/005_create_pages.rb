# An html page on the system.
class CreatePages < ActiveRecord::Migration[5.1]
  def self.up
    create_table :pages do |t|
      t.belongs_to :parent
      t.boolean :is_authority_controlled, null: false, default: false
      t.string :filename, null: false
      t.string :title, null: false
      t.text :description
      t.text :content
      t.timestamps
    end
    change_table :pages do |t|
      t.index %i(parent_id filename), name: 'path', unique: true
    end
  end

  def self.down
    drop_table :pages
  end
end
