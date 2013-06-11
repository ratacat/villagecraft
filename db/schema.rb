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

ActiveRecord::Schema.define(:version => 20130611191656) do

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
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
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
  end

  create_table "events_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.boolean "confirmed"
    t.integer "guests"
  end

  add_index "events_users", ["event_id"], :name => "index_events_users_on_event_id"
  add_index "events_users", ["user_id"], :name => "index_events_users_on_user_id"

  create_table "locations", :force => true do |t|
    t.string   "street"
    t.string   "city"
    t.string   "zip"
    t.string   "state"
    t.integer  "owner_id"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "locations", ["owner_id"], :name => "index_locations_on_owner_id"

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
    t.string   "name_first"
    t.string   "name_last"
    t.string   "username"
    t.integer  "number_of_events_attended"
    t.integer  "number_of_events_hosted"
    t.integer  "number_of_events_reserved"
    t.integer  "number_of_people_met"
    t.string   "email",                     :default => "", :null => false
    t.string   "encrypted_password",        :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "vclasses", :force => true do |t|
    t.integer  "admin_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "title"
  end

  add_index "vclasses", ["admin_id"], :name => "index_vclasses_on_admin_id"

end
