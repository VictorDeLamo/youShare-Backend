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

ActiveRecord::Schema[7.0].define(version: 2024_04_30_162314) do
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

  create_table "boosts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "hilo_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hilo_id"], name: "index_boosts_on_hilo_id"
    t.index ["user_id"], name: "index_boosts_on_user_id"
  end

  create_table "comment_boosts", force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_boosts_on_comment_id"
    t.index ["user_id"], name: "index_comment_boosts_on_user_id"
  end

  create_table "comment_reactions", force: :cascade do |t|
    t.integer "comment_id", null: false
    t.integer "user_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_reactions_on_comment_id"
    t.index ["user_id"], name: "index_comment_reactions_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "hilo_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "parent_id"
    t.integer "likes", default: 0
    t.integer "dislikes", default: 0
    t.integer "boosts_count", default: 0
    t.index ["hilo_id"], name: "index_comments_on_hilo_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "hilos", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "likes", default: 0
    t.string "url"
    t.integer "dislikes", default: 0
    t.integer "magazine_id", null: false
    t.integer "user_id"
    t.integer "boosts_count"
    t.index ["magazine_id"], name: "index_hilos_on_magazine_id"
  end

  create_table "magazines", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "description"
    t.text "rules"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_magazines_on_user_id"
  end

  create_table "reactions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "hilo_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hilo_id"], name: "index_reactions_on_hilo_id"
    t.index ["user_id", "hilo_id"], name: "index_reactions_on_user_id_and_hilo_id", unique: true
    t.index ["user_id"], name: "index_reactions_on_user_id"
  end

  create_table "suscripciones", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "magazine_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["magazine_id"], name: "index_suscripciones_on_magazine_id"
    t.index ["user_id"], name: "index_suscripciones_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.text "description"
    t.string "cover"
    t.string "avatar"
    t.string "api_key"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "boosts", "hilos"
  add_foreign_key "boosts", "users"
  add_foreign_key "comment_boosts", "comments"
  add_foreign_key "comment_boosts", "users"
  add_foreign_key "comment_reactions", "comments"
  add_foreign_key "comment_reactions", "users"
  add_foreign_key "comments", "hilos"
  add_foreign_key "comments", "users"
  add_foreign_key "hilos", "magazines"
  add_foreign_key "magazines", "users"
  add_foreign_key "reactions", "hilos"
  add_foreign_key "reactions", "users"
  add_foreign_key "suscripciones", "magazines"
  add_foreign_key "suscripciones", "users"
end
