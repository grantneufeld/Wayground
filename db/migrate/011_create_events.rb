# An event.
class CreateEvents < ActiveRecord::Migration[5.1]
  def self.up
    create_table :events do |t|
      t.belongs_to :user
      t.datetime :start_at, null: false
      t.datetime :end_at
      t.string :timezone, limit: 31
      t.boolean :is_allday, null: false, default: false
      t.boolean :is_draft, null: false, default: false
      t.boolean :is_approved, null: false, default: false
      t.boolean :is_wheelchair_accessible, null: false, default: false
      t.boolean :is_adults_only, null: false, default: false
      t.boolean :is_tentative, null: false, default: false
      t.boolean :is_cancelled, null: false, default: false
      t.boolean :is_featured, null: false, default: false
      t.string :title, null: false, limit: 255
      t.string :description, limit: 511
      t.text :content, limit: 8191
      # the following fields should eventually move to separate tables
      # (Group & Person for organizer, Location for location)
      t.string :organizer, limit: 255
      t.string :organizer_url, limit: 255
      t.string :location, limit: 255
      t.string :address, limit: 255
      t.string :city, limit: 255
      t.string :province, limit: 31
      t.string :country, limit: 2
      t.string :location_url, limit: 255
      t.timestamps
    end
    change_table :events do |t|
      t.index %i[start_at end_at is_allday is_approved is_draft is_cancelled], name: 'dates'
      t.index [:title]
    end
  end

  def self.down
    drop_table :events
  end
end
