# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_31_143530) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alerts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "radius", default: 5.0, null: false
    t.index ["user_id"], name: "index_alerts_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.bigint "incident_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_comments_on_incident_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "incidents", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "address"
    t.boolean "status"
    t.string "category"
    t.bigint "user_id", null: false
    t.string "photo_url"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "date"
    t.index ["latitude", "longitude"], name: "index_incidents_on_latitude_and_longitude"
    t.index ["user_id"], name: "index_incidents_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "alert_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false
    t.bigint "incident_id"
    t.index ["alert_id"], name: "index_notifications_on_alert_id"
    t.index ["incident_id"], name: "index_notifications_on_incident_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "nickname"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.boolean "vote"
    t.bigint "user_id", null: false
    t.bigint "incident_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["incident_id"], name: "index_votes_on_incident_id"
    t.index ["user_id", "incident_id"], name: "index_votes_on_user_id_and_incident_id", unique: true
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "users"
  add_foreign_key "comments", "incidents"
  add_foreign_key "comments", "users"
  add_foreign_key "incidents", "users"
  add_foreign_key "notifications", "alerts"
  add_foreign_key "notifications", "incidents"
  add_foreign_key "notifications", "users"
  add_foreign_key "votes", "incidents"
  add_foreign_key "votes", "users"
end
