class CreateOfficeHolders < ActiveRecord::Migration
  def change
    create_table :office_holders do |t|
      t.belongs_to :office, null: false
      t.belongs_to :person, null: false
      t.belongs_to :previous, null: false
      t.date :start_on
      t.date :end_on
      t.timestamps
    end
    add_index :office_holders, [:office_id, :person_id, :start_on]
    add_index :office_holders, [:person_id, :office_id, :start_on]
    add_index :office_holders, :previous_id
  end
end
