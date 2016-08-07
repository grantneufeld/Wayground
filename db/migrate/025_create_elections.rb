# An election (may be for multiple offices)
class CreateElections < ActiveRecord::Migration
  def change
    create_table :elections do |t|
      t.belongs_to :level
      t.string :filename, limit: 63, null: false
      t.string :name, null: false
      t.date :start_on
      t.date :end_on
      t.text :description
      t.text :url
      t.timestamps
    end
    add_index :elections, %i(level_id end_on)
    add_index :elections, %i(level_id filename)
  end
end
