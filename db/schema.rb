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

ActiveRecord::Schema.define(version: 20180228082448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forwarders", force: :cascade do |t|
    t.string   "name"
    t.string   "host"
    t.integer  "group_id"
    t.integer  "store_id"
    t.string   "kafka_broker_hosts"
    t.string   "zookeeper_hosts"
    t.string   "kafka_topics"
    t.string   "heartbeat_url"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "receiver_host"
    t.string   "zookeeper_hosts"
    t.string   "kafka_broker_hosts"
    t.string   "receiver_heartbeat_url"
    t.string   "kafka_manager_host"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "kafka_topic_partition",  default: 0, null: false
  end

  create_table "service_configs", force: :cascade do |t|
    t.string   "ip_address"
    t.json     "config_json"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "services", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "group_id"
    t.integer  "store_id"
    t.string   "produce_url"
    t.string   "kibana_host"
    t.string   "kafka_topics"
    t.integer  "kafka_topic_partition"
    t.string   "heartbeat_url"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "forwarder_id",          default: 0, null: false
  end

  create_table "stores", force: :cascade do |t|
    t.string   "name"
    t.string   "elasticsearch_host"
    t.string   "kibana_host"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",      default: "", null: false
    t.string   "username",                null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
