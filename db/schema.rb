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

ActiveRecord::Schema.define(version: 20150128201043) do

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.string   "document_id",   limit: 255
    t.string   "title",         limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "user_type",     limit: 255
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "indexing_exceptions", force: :cascade do |t|
    t.string   "pid",                  limit: 255
    t.text     "solr_document"
    t.string   "dor_services_version", limit: 255
    t.text     "exception"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "indexing_exceptions", ["pid"], name: "index_indexing_exceptions_on_pid"

  create_table "robots", force: :cascade do |t|
    t.string   "wf",         limit: 255
    t.string   "process",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "user_type",    limit: 255
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "users", force: :cascade do |t|
    t.string   "sunetid",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
