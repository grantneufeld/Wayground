# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 2) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider",    :null => false
    t.string   "uid",         :null => false
    t.string   "nickname"
    t.string   "name"
    t.string   "email"
    t.string   "location"
    t.string   "url"
    t.string   "image_url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["provider", "uid"], :name => "auth", :unique => true
  add_index "authentications", ["user_id", "provider"], :name => "user"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash",        :limit => 128
    t.string   "name"
    t.boolean  "is_verified_realname",                :default => false, :null => false
    t.boolean  "email_confirmed",                     :default => false, :null => false
    t.string   "confirmation_token",   :limit => 128
    t.string   "remember_token",       :limit => 128
    t.string   "filename",             :limit => 63
    t.string   "location"
    t.text     "about"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "email", :unique => true
  add_index "users", ["filename"], :name => "filename", :unique => true
  add_index "users", ["remember_token"], :name => "remember_token", :unique => true

end
