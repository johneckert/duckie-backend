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

ActiveRecord::Schema.define(version: 20180322183805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversation_keywords", force: :cascade do |t|
    t.bigint "conversation_id"
    t.bigint "keyword_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_conversation_keywords_on_conversation_id"
    t.index ["keyword_id"], name: "index_conversation_keywords_on_keyword_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "user_id"
    t.text "transcript"
    t.binary "audio"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_conversations_on_user_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.text "word"
    t.float "relevance"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "first_name"
    t.text "last_name"
    t.text "email"
    t.text "password_digest"
  end

  add_foreign_key "conversation_keywords", "conversations"
  add_foreign_key "conversation_keywords", "keywords"
  add_foreign_key "conversations", "users"
end
