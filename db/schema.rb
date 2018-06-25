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

ActiveRecord::Schema.define(version: 2018_06_25_075900) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "barito_apps", force: :cascade do |t|
    t.string "name"
    t.string "app_group"
    t.string "tps_config"
    t.string "secret_key"
    t.string "cluster_name"
    t.string "app_status"
    t.string "setup_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "log_count", default: 0
    t.string "consul_host"
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

end
