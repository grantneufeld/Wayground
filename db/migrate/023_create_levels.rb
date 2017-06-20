# Levels of government.
# May be hierarchical (e.g., Federal -> Provincial/State -> Municipal -> Community)
class CreateLevels < ActiveRecord::Migration[5.1]
  def change
    create_table :levels do |t|
      t.belongs_to :parent
      t.string :filename, limit: 63, null: false
      t.string :name, null: false
      t.text :url
      t.timestamps
    end
    add_index :levels, %i(parent_id filename), name: 'levels_parent_idx'
    add_index :levels, [:filename], name: 'levels_filename_idx', unique: true
  end
end
