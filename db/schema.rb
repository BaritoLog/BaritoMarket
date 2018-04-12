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

ActiveRecord::Schema.define(version: 20180411041123) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_groups", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "apps", force: :cascade do |t|
    t.string   "name"
    t.integer  "log_template_id"
    t.integer  "app_group_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "log_templates", force: :cascade do |t|
    t.string   "name"
    t.integer  "tps_limit"
    t.integer  "zookeeper_instances"
    t.integer  "kafka_instances"
    t.integer  "es_instances"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  create_table "user_groups", force: :cascade do |t|
    t.string   "name"
    t.integer  "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "user_groups", ["deleted_at"], name: "index_user_groups_on_deleted_at", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",      default: "", null: false
    t.string   "username",                null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
  end

  add_index "users", ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
