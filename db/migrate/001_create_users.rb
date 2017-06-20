# Users of the system. To be linked with Authorities to provide access control.
class CreateUsers < ActiveRecord::Migration[5.1]
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :password_hash, limit: 128
      t.string :name
      t.boolean :is_verified_realname, default: false, null: false
      t.boolean :email_confirmed, default: false, null: false
      t.string :confirmation_token, limit: 128
      t.string :remember_token, limit: 128
      t.string :filename, limit: 63
      t.string :timezone, limit: 31
      t.string :location
      t.text :about
      t.timestamps
    end
    change_table :users do |t|
      t.index [:email], name: 'email', unique: true
      t.index [:remember_token], name: 'remember_token', unique: true
      t.index [:filename], name: 'filename', unique: true
    end
  end

  def self.down
    drop_table :users
  end
end
