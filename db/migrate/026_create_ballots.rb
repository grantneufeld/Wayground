# Ballot for an office in an election
class CreateBallots < ActiveRecord::Migration[5.1]
  def change
    create_table :ballots do |t|
      t.belongs_to :election, null: false
      t.belongs_to :office, null: false
      t.integer :position, null: false, default: 999
      t.string :section
      t.date :term_start_on
      t.date :term_end_on
      t.boolean :is_byelection, null: false, default: false
      t.string :url
      t.text :description
      t.timestamps
    end
    # only allow one ballot for a given office in a given election
    add_index :ballots, %i(election_id office_id), unique: true
    add_index :ballots, %i(election_id office_id position)
  end
end
