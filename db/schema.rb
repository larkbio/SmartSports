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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160226100731) do

  create_table "activities", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.boolean  "manual"
    t.string   "source"
    t.string   "group"
    t.string   "activity"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "steps"
    t.integer  "duration"
    t.float    "distance"
    t.float    "elevation"
    t.float    "calories"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "intensity"
    t.boolean  "favourite",        default: false
    t.integer  "activity_type_id"
  end

  add_index "activities", ["user_id", "created_at"], name: "index_activities_on_user_id_and_created_at"
  add_index "activities", ["user_id"], name: "index_activities_on_user_id"

  create_table "activity_types", force: true do |t|
    t.string "name"
    t.float  "kcal"
    t.string "category"
    t.string "lang"
  end

  create_table "click_records", force: true do |t|
    t.integer  "user_id"
    t.datetime "operation_time"
    t.string   "operation"
    t.string   "url"
    t.string   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "success"
    t.integer  "row_id"
    t.string   "msg"
    t.string   "source"
  end

  add_index "click_records", ["user_id", "operation_time", "operation"], name: "index_click_records"
  add_index "click_records", ["user_id"], name: "index_click_records_on_user_id"

  create_table "connections", force: true do |t|
    t.string   "name"
    t.string   "type"
    t.text     "data",        limit: 1024
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.datetime "synced_at"
    t.integer  "sync_status", limit: 1,    default: 0
  end

  add_index "connections", ["name", "user_id"], name: "index_connection_on_name_and_user_id", unique: true

  create_table "custom_form_elements", force: true do |t|
    t.integer "custom_form_id"
    t.integer "order_index"
    t.string  "property_code"
    t.text    "defaults"
  end

  create_table "custom_forms", force: true do |t|
    t.integer "user_id"
    t.integer "order_index"
    t.string  "form_name"
    t.string  "image_name"
    t.string  "form_tag"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "diets", force: true do |t|
    t.integer  "user_id"
    t.string   "diet_type"
    t.string   "source"
    t.text     "name"
    t.datetime "date"
    t.float    "calories"
    t.float    "carbs"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "favourite",    default: false
    t.float    "fat"
    t.float    "prot"
    t.string   "category"
    t.integer  "food_type_id"
  end

  create_table "family_histories", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.string   "relative"
    t.string   "disease"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "family_histories", ["user_id", "created_at"], name: "index_family_histories_on_user_id_and_created_at"
  add_index "family_histories", ["user_id", "source"], name: "index_family_histories_on_user_id_and_source"
  add_index "family_histories", ["user_id"], name: "index_family_histories_on_user_id"

  create_table "food_types", force: true do |t|
    t.string "name"
    t.string "category"
    t.string "amount"
    t.float  "kcal"
    t.float  "prot"
    t.float  "carb"
    t.float  "fat"
    t.string "lang"
  end

  create_table "friendships", force: true do |t|
    t.integer  "user1_id"
    t.integer  "user2_id"
    t.boolean  "authorized"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["user1_id", "user2_id"], name: "index_friendships_on_user1_id_and_user2_id"

  create_table "genetics_types", force: true do |t|
    t.string "name"
    t.string "category"
  end

  create_table "illness_types", force: true do |t|
    t.string "name"
  end

  create_table "labresults", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.string   "category"
    t.float    "hba1c"
    t.float    "ldl_chol"
    t.float    "egfr_epi"
    t.string   "ketone"
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lifestyle_types", force: true do |t|
    t.string "name"
    t.string "category"
  end

  create_table "lifestyles", force: true do |t|
    t.integer  "user_id"
    t.datetime "start_time"
    t.string   "source"
    t.string   "group"
    t.string   "name"
    t.float    "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "end_time"
    t.boolean  "favourite",       default: false
    t.integer  "illness_type_id"
    t.string   "pain_type_name"
    t.integer  "period_volume"
    t.text     "details"
  end

  add_index "lifestyles", ["user_id", "created_at"], name: "index_lifestyles_on_user_id_and_created_at"
  add_index "lifestyles", ["user_id", "group"], name: "index_lifestyles_on_user_id_and_group"
  add_index "lifestyles", ["user_id", "name"], name: "index_lifestyles_on_user_id_and_name"
  add_index "lifestyles", ["user_id"], name: "index_lifestyles_on_user_id"

  create_table "measurements", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.datetime "date"
    t.integer  "diastolicbp"
    t.integer  "systolicbp"
    t.integer  "pulse"
    t.integer  "SPO2"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "blood_sugar"
    t.float    "weight"
    t.float    "waist"
    t.string   "meas_type"
    t.boolean  "favourite",        default: false
    t.float    "stress_amount"
    t.integer  "blood_sugar_time"
  end

  add_index "measurements", ["user_id", "created_at"], name: "index_measurements_on_user_id_and_created_at"
  add_index "measurements", ["user_id"], name: "index_measurements_on_user_id"

  create_table "medication_types", force: true do |t|
    t.string "group"
    t.string "name"
    t.float  "dosage"
  end

  create_table "medications", force: true do |t|
    t.integer  "user_id"
    t.datetime "date"
    t.string   "source"
    t.integer  "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "medication_type_id"
    t.boolean  "favourite",          default: false
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.string   "title"
    t.text     "detail"
    t.integer  "notification_type", limit: 2
    t.datetime "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "notification_data"
    t.datetime "remind_at"
    t.integer  "created_by"
    t.integer  "form_id"
    t.text     "location"
    t.text     "location_url"
    t.datetime "dismissed_on"
    t.boolean  "dismissed"
    t.boolean  "recurring"
    t.string   "recurrence_data"
    t.string   "form_name"
    t.string   "default_data"
  end

  add_index "notifications", ["user_id", "date"], name: "index_notifications_on_user_id_and_date"
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id"

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true

  create_table "oauth_applications", force: true do |t|
    t.string   "name",                      null: false
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.text     "redirect_uri",              null: false
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true

  create_table "profiles", force: true do |t|
    t.integer  "user_id"
    t.string   "firstname"
    t.string   "lastname"
    t.float    "weight"
    t.float    "height"
    t.string   "sex"
    t.date     "dateofbirth"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "smoke",        default: false
    t.boolean  "insulin",      default: false
    t.string   "default_lang"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id", unique: true

  create_table "sensor_data", force: true do |t|
    t.string   "sensor_id"
    t.string   "sensor_type"
    t.integer  "sensor_measurement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sensor_data", ["sensor_measurement_id"], name: "index_sensor_data_on_sensor_measurement_id"

  create_table "sensor_measurements", force: true do |t|
    t.integer  "user_id"
    t.string   "group"
    t.text     "rr_data",    limit: 2097152
    t.text     "hr_data",    limit: 2097152
    t.datetime "start_time"
    t.text     "cr_data",    limit: 2097152
    t.integer  "duration"
    t.string   "sensors"
    t.boolean  "favourite"
    t.string   "version"
    t.datetime "end_time"
  end

  create_table "sensor_segments", force: true do |t|
    t.datetime "start_time"
    t.text     "data_a",          limit: 2097152
    t.text     "data_b",          limit: 2097152
    t.integer  "sensor_datum_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sensor_segments", ["sensor_datum_id"], name: "index_sensor_segments_on_sensor_datum_id"

  create_table "summaries", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.datetime "date"
    t.string   "activity"
    t.string   "group"
    t.float    "total_duration"
    t.float    "distance"
    t.integer  "steps"
    t.float    "calories"
    t.float    "elevation"
    t.datetime "synced_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "soft_duration"
    t.float    "moderate_duration"
    t.float    "hard_duration"
    t.boolean  "sync_final"
  end

  add_index "summaries", ["user_id", "created_at"], name: "index_summaries_on_user_id_and_created_at"
  add_index "summaries", ["user_id"], name: "index_summaries_on_user_id"

  create_table "tracker_data", force: true do |t|
    t.integer  "user_id"
    t.string   "source"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "activity"
    t.string   "group"
    t.boolean  "manual"
    t.float    "duration"
    t.float    "distance"
    t.integer  "steps"
    t.string   "intensity"
    t.float    "calories"
    t.datetime "synced_at"
    t.boolean  "sync_final"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracker_data", ["user_id", "start_time", "sync_final"], name: "index_tracker_data_on_user_id_and_start_time_and_sync_final"
  add_index "tracker_data", ["user_id", "start_time"], name: "index_tracker_data_on_user_id_and_start_time"
  add_index "tracker_data", ["user_id"], name: "index_tracker_data_on_user_id"

  create_table "users", force: true do |t|
    t.string   "name",                                            null: false
    t.string   "username",                                        null: false
    t.string   "email",                                           null: false
    t.string   "crypted_password",                                null: false
    t.string   "salt",                                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.boolean  "admin",                           default: false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.boolean  "doctor"
    t.string   "dev_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token"

end
