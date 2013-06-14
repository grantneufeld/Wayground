class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.belongs_to :item, polymorphic: true, null: false
      t.integer :position, null: false, default: 999
      t.boolean :is_public, null: false, default: false
      t.datetime :confirmed_at
      t.datetime :expires_at
      t.string :name
      t.string :organization
      t.string :email
      t.string :twitter
      t.string :url
      t.string :phone
      t.string :phone2
      t.string :fax
      t.string :address1
      t.string :address2
      t.string :city
      t.string :province
      t.string :country
      t.string :postal
      t.timestamps
    end
    add_index :contacts, [:item_type, :item_id, :position]
    add_index :contacts, [:confirmed_at, :expires_at]
    add_index :contacts, :name
    add_index :contacts, :email
    add_index :contacts, [:country, :province, :city]
  end
end
