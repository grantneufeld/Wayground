# User authentications via login & password or external providers (e.g., oauth).
class CreateAuthentications < ActiveRecord::Migration[5.1]
  def self.up
    create_table :authentications do |t|
      t.belongs_to :user
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :nickname
      t.string :name
      t.string :email
      t.string :location
      t.string :url
      t.string :image_url
      t.text :description
      t.timestamps
    end
    change_table :authentications do |t|
      t.index %i[provider uid], name: 'auth', unique: true
      t.index %i[user_id provider], name: 'user'
    end
  end

  def self.down
    drop_table :authentications
  end
end
