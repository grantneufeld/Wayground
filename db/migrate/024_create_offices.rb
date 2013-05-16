class CreateOffices < ActiveRecord::Migration
  def change
    create_table :offices do |t|
      t.belongs_to :level, null: false
      t.belongs_to :previous # the previous office — the one that this one replaced
      t.string :filename, limit: 63, null: false
      t.string :name, null: false
      t.string :title
      t.integer :position, null: false, default: 0
      t.date :established_on
      t.date :ended_on
      t.text :description
      t.text :url
      t.timestamps
    end
    add_index :offices, [:level_id, :position], name: 'offices_level_position_idx'
    add_index :offices, [:level_id, :filename], name: 'offices_filename_idx', unique: true
    add_index :offices, [:previous_id], name: 'offices_previous_idx'
  end
end
