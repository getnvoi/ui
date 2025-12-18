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

ActiveRecord::Schema[8.1].define(version: 2025_12_18_091105) do
  create_table "contacts", force: :cascade do |t|
    t.string "city"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "state"
    t.datetime "updated_at", null: false
  end

  create_table "phones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "number"
    t.string "phone_type"
    t.integer "sibling_id", null: false
    t.datetime "updated_at", null: false
    t.index ["sibling_id"], name: "index_phones_on_sibling_id"
  end

  create_table "siblings", force: :cascade do |t|
    t.string "age"
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_siblings_on_contact_id"
  end

  add_foreign_key "phones", "siblings"
  add_foreign_key "siblings", "contacts"
end
