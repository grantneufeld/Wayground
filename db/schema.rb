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

ActiveRecord::Schema.define(:version => 5) do

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

  create_table "authorities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "authorized_by_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "area",             :limit => 31
    t.boolean  "is_owner"
    t.boolean  "can_create"
    t.boolean  "can_view"
    t.boolean  "can_edit"
    t.boolean  "can_delete"
    t.boolean  "can_invite"
    t.boolean  "can_permit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorities", ["area", "user_id"], :name => "area"
  add_index "authorities", ["authorized_by_id", "user_id", "area"], :name => "authorizer"
  add_index "authorities", ["item_id", "item_type", "user_id"], :name => "item"
  add_index "authorities", ["user_id", "item_id", "item_type", "area"], :name => "user_map", :unique => true

  create_table "pages", :force => true do |t|
    t.integer  "parent_id"
    t.boolean  "is_authority_controlled", :default => false, :null => false
    t.string   "filename",                                   :null => false
    t.string   "title",                                      :null => false
    t.text     "description"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["parent_id", "filename"], :name => "path", :unique => true

  create_table "paths", :force => true do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.text     "sitepath",   :null => false
    t.text     "redirect"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paths", ["item_type", "item_id"], :name => "item_idx"
  add_index "paths", ["sitepath"], :name => "sitepath", :unique => true

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
