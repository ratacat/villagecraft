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

ActiveRecord::Schema.define(:version => 20130716062020) do

  create_table "attendances", :force => true do |t|
    t.integer  "event_id"
    t.integer  "user_id"
    t.boolean  "confirmed"
    t.integer  "guests"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "attendances", ["event_id"], :name => "index_attendances_on_event_id"
  add_index "attendances", ["user_id"], :name => "index_attendances_on_user_id"

  create_table "courses", :force => true do |t|
    t.integer  "vclass_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  add_index "courses", ["vclass_id"], :name => "index_courses_on_vclass_id"

  create_table "events", :force => true do |t|
    t.string   "title"
    t.text     "description",   :limit => 255
    t.datetime "created_at",                                                  :null => false
    t.datetime "updated_at",                                                  :null => false
    t.integer  "course_id"
    t.integer  "host_id"
    t.integer  "location_id"
    t.integer  "min_attendees"
    t.integer  "max_attendees"
    t.boolean  "open"
    t.integer  "max_observers"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "secret"
    t.string   "short_title"
    t.decimal  "price",                        :precision => 10, :scale => 2
    t.integer  "venue_id"
    t.string   "uuid"
  end

  add_index "events", ["venue_id"], :name => "index_events_on_venue_id"

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "img_file_name"
    t.string   "img_content_type"
    t.integer  "img_file_size"
    t.datetime "img_updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.string   "state"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.string   "address"
    t.string   "country"
    t.string   "state_code"
    t.string   "time_zone"
  end

  create_table "reviews", :force => true do |t|
    t.integer  "vclass_id"
    t.integer  "author_id"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "reviews", ["author_id"], :name => "index_reviews_on_author_id"
  add_index "reviews", ["vclass_id"], :name => "index_reviews_on_vclass_id"

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.integer  "number_of_events_attended"
    t.integer  "number_of_events_hosted"
    t.integer  "number_of_events_reserved"
    t.integer  "number_of_people_met"
    t.string   "email",                     :default => "",   :null => false
    t.string   "encrypted_password",        :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "location_id"
    t.string   "uuid"
    t.integer  "profile_image_id"
    t.string   "auth_provider"
    t.string   "auth_provider_uid"
    t.boolean  "has_set_password",          :default => true
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["location_id"], :name => "index_users_on_location_id"
  add_index "users", ["profile_image_id"], :name => "index_users_on_profile_image_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vclasses", :force => true do |t|
    t.integer  "admin_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  add_index "vclasses", ["admin_id"], :name => "index_vclasses_on_admin_id"

  create_table "venues", :force => true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.integer  "location_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "uuid"
  end

  add_index "venues", ["location_id"], :name => "index_venues_on_location_id"
  add_index "venues", ["owner_id"], :name => "index_venues_on_owner_id"

end
