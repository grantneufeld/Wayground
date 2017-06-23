# A candidate (Person) in an election.
class CreateCandidates < ActiveRecord::Migration[5.1]
  def change
    create_table :candidates do |t|
      t.belongs_to :ballot, null: false
      t.belongs_to :person, null: false
      t.belongs_to :party
      t.belongs_to :submitter
      t.string :filename, null: false
      t.string :name, null: false
      t.boolean :is_rumoured, null: false, default: false
      t.boolean :is_confirmed, null: false, default: false
      t.boolean :is_incumbent, null: false, default: false
      t.boolean :is_leader, null: false, default: false
      t.boolean :is_acclaimed, null: false, default: false
      t.boolean :is_elected, null: false, default: false
      t.date :announced_on
      t.date :quit_on
      t.integer :vote_count, default: 0, null: false
      t.timestamps
    end
    add_index :candidates, %i[ballot_id person_id], unique: true
    add_index :candidates, %i[ballot_id name], unique: true
    add_index :candidates, %i[ballot_id filename], unique: true
    add_index :candidates, %i[ballot_id is_confirmed name]
    add_index :candidates, %i[ballot_id vote_count name]
  end
end
