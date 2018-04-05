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

ActiveRecord::Schema.define(version: 20180405051628) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "client_groups", force: :cascade do |t|
    t.integer  "client_id"
    t.integer  "user_group_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.datetime "deleted_at"
  end

  add_index "client_groups", ["client_id"], name: "index_client_groups_on_client_id", using: :btree
  add_index "client_groups", ["deleted_at"], name: "index_client_groups_on_deleted_at", using: :btree
  add_index "client_groups", ["user_group_id"], name: "index_client_groups_on_user_group_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "stream_id"
    t.integer  "store_id"
    t.string   "produce_url"
    t.string   "kibana_host"
    t.string   "kafka_topics"
    t.integer  "kafka_topic_partition"
    t.string   "heartbeat_url"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "forwarder_id",          default: 0, null: false
    t.string   "application_secret"
    t.integer  "user_id"
    t.datetime "deleted_at"
  end

  add_index "clients", ["deleted_at"], name: "index_clients_on_deleted_at", using: :btree
  add_index "clients", ["user_id"], name: "index_clients_on_user_id", using: :btree

  create_table "databags", force: :cascade do |t|
    t.string   "ip_address"
    t.json     "data"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "tags",       default: "", null: false
    t.datetime "deleted_at"
  end

  add_index "databags", ["deleted_at"], name: "index_databags_on_deleted_at", using: :btree

  create_table "forwarders", force: :cascade do |t|
    t.string   "name"
    t.string   "host"
    t.integer  "stream_id"
    t.integer  "store_id"
    t.string   "kafka_broker_hosts"
    t.string   "zookeeper_hosts"
    t.string   "kafka_topics"
    t.string   "heartbeat_url"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "deleted_at"
  end

  add_index "forwarders", ["deleted_at"], name: "index_forwarders_on_deleted_at", using: :btree

  create_table "stores", force: :cascade do |t|
    t.string   "name"
    t.string   "elasticsearch_host"
    t.string   "kibana_host"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.datetime "deleted_at"
  end

  add_index "stores", ["deleted_at"], name: "index_stores_on_deleted_at", using: :btree

  create_table "streams", force: :cascade do |t|
    t.string   "name"
    t.string   "receiver_host"
    t.string   "zookeeper_hosts"
    t.string   "kafka_broker_hosts"
    t.string   "receiver_heartbeat_url"
    t.string   "kafka_manager_host"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "kafka_topic_partition",  default: 0, null: false
    t.integer  "databag_id"
    t.string   "receiver_port"
    t.datetime "deleted_at"
  end

  add_index "streams", ["deleted_at"], name: "index_streams_on_deleted_at", using: :btree

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
