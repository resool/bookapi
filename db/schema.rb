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

ActiveRecord::Schema[8.1].define(version: 2026_10_19_150100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "item_status", ["available", "loaned", "in_repair", "lost", "withdrawn"]
  create_enum "member_status", ["active", "suspended", "closed"]

  create_table "authors", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_authors_on_name", unique: true
  end

  create_table "authorships", force: :cascade do |t|
    t.bigint "author_id", null: false
    t.bigint "work_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_authorships_on_author_id"
    t.index ["work_id", "author_id"], name: "index_authorships_on_work_id_and_author_id", unique: true
  end

  create_table "editions", force: :cascade do |t|
    t.bigint "work_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "translator"
    t.string "publisher"
    t.integer "published_year"
    t.string "isbn"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isbn"], name: "index_editions_on_isbn", unique: true, where: "(isbn IS NOT NULL)"
    t.index ["work_id"], name: "index_editions_on_work_id"
  end

  create_table "idempotency_keys", force: :cascade do |t|
    t.string "key", null: false
    t.string "request_fingerprint", null: false
    t.integer "response_status"
    t.text "response_body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_idempotency_keys_on_key", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.bigint "edition_id", null: false
    t.string "sku", null: false
    t.enum "status", default: "available", null: false, enum_type: "item_status"
    t.string "condition", null: false
    t.date "acquired_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["edition_id"], name: "index_items_on_edition_id"
    t.index ["sku"], name: "index_items_on_sku", unique: true
  end

  create_table "loans", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "member_id", null: false
    t.datetime "rented_at", null: false
    t.datetime "due_at", null: false
    t.datetime "returned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_loans_on_item_id"
    t.index ["item_id"], name: "index_loans_on_item_id_active", unique: true, where: "(returned_at IS NULL)"
    t.index ["member_id"], name: "index_loans_on_member_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "member_number", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.enum "status", default: "active", null: false, enum_type: "member_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_members_on_email", unique: true
    t.index ["member_number"], name: "index_members_on_member_number", unique: true
  end

  create_table "works", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_works_on_title"
  end

  add_foreign_key "authorships", "authors"
  add_foreign_key "authorships", "works"
  add_foreign_key "editions", "works"
  add_foreign_key "items", "editions"
  add_foreign_key "loans", "items"
  add_foreign_key "loans", "members"
end
