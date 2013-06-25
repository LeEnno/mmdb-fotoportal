# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130625104928) do

  create_table "appearances", :force => true do |t|
    t.integer "picture_id", :null => false
    t.integer "person_id",  :null => false
  end

  add_index "appearances", ["picture_id", "person_id"], :name => "index_appearances_on_picture_id_and_person_id"

  create_table "folders", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "folders", ["parent_id"], :name => "index_folders_on_parent_id"
  add_index "folders", ["user_id"], :name => "index_folders_on_user_id"

  create_table "keywords", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "keywords_pictures", :force => true do |t|
    t.integer "picture_id", :null => false
    t.integer "keyword_id", :null => false
  end

  add_index "keywords_pictures", ["picture_id", "keyword_id"], :name => "index_pictures_keywords_on_picture_id_and_keyword_id"

  create_table "persons", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pictures", :force => true do |t|
    t.string   "title",         :null => false
    t.string   "camera"
    t.string   "path_hash",     :null => false
    t.integer  "width",         :null => false
    t.integer  "height",        :null => false
    t.integer  "filesize",      :null => false
    t.string   "location"
    t.float    "longitude"
    t.float    "latitude"
    t.float    "exposure_time"
    t.integer  "iso"
    t.string   "aperture"
    t.integer  "focal_length"
    t.string   "color_space"
    t.integer  "color_depth"
    t.boolean  "has_flash"
    t.datetime "taken_at"
    t.integer  "mean_red"
    t.integer  "mean_green"
    t.integer  "mean_blue"
    t.integer  "mean_yellow"
    t.integer  "mean_orange"
    t.integer  "mean_violet"
    t.integer  "mean_magenta"
    t.integer  "mean_cyan"
    t.integer  "mean_brown"
    t.integer  "mean_white"
    t.integer  "mean_black"
    t.integer  "folder_id",     :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "extension"
  end

  add_index "pictures", ["folder_id"], :name => "index_pictures_on_folder_id"

  create_table "sessions", :force => true do |t|
    t.datetime "expires_at"
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["user_id"], :name => "index_sessions_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "firstname",  :null => false
    t.string   "surname",    :null => false
    t.string   "email",      :null => false
    t.string   "password",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
