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

ActiveRecord::Schema.define(version: 2018_07_02_093138) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "barito_apps", force: :cascade do |t|
    t.string "name"
    t.string "secret_key"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "log_count", default: 0
    t.bigint "app_group_id"
    t.string "topic_name"
    t.integer "max_tps"
    t.index ["app_group_id"], name: "index_barito_apps_on_app_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name"
  end

  create_table "infrastructures", force: :cascade do |t|
    t.string "name"
    t.string "cluster_name"
    t.string "capacity"
    t.string "provisioning_status"
    t.string "status"
    t.string "consul_host"
    t.bigint "app_group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_group_id"], name: "index_infrastructures_on_app_group_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: ""
    t.boolean "admin", default: false, null: false
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true, where: "((email IS NOT NULL) AND ((email)::text <> ''::text))"
    t.index ["username"], name: "index_users_on_username", unique: true, where: "((username IS NOT NULL) AND ((username)::text <> ''::text))"
  end

end
