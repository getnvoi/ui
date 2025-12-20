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

ActiveRecord::Schema[8.1].define(version: 2025_12_20_000001) do
  create_table "aeno_contact_relationships", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.integer "related_contact_id", null: false
    t.string "relation_type"
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_aeno_contact_relationships_on_contact_id"
    t.index ["related_contact_id"], name: "index_aeno_contact_relationships_on_related_contact_id"
  end

  create_table "aeno_contacts", force: :cascade do |t|
    t.string "address"
    t.date "birth_date"
    t.string "city"
    t.string "company"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "job_title"
    t.string "name"
    t.text "notes"
    t.string "state"
    t.datetime "updated_at", null: false
  end

  create_table "aeno_phones", force: :cascade do |t|
    t.integer "contact_id", null: false
    t.datetime "created_at", null: false
    t.string "number"
    t.string "phone_type"
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_aeno_phones_on_contact_id"
  end

  add_foreign_key "aeno_contact_relationships", "aeno_contacts", column: "contact_id"
  add_foreign_key "aeno_contact_relationships", "aeno_contacts", column: "related_contact_id"
  add_foreign_key "aeno_phones", "aeno_contacts", column: "contact_id"
end
