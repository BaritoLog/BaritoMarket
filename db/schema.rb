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

ActiveRecord::Schema.define(version: 2024_02_19_110029) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "app_group_bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "app_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_group_id"], name: "index_app_group_bookmarks_on_app_group_id"
    t.index ["user_id"], name: "index_app_group_bookmarks_on_user_id"
  end

  create_table "app_group_roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "app_group_teams", force: :cascade do |t|
    t.bigint "app_group_id"
    t.bigint "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_group_id"], name: "index_app_group_teams_on_app_group_id"
    t.index ["group_id"], name: "index_app_group_teams_on_group_id"
  end

  create_table "app_group_users", force: :cascade do |t|
    t.bigint "app_group_id"
    t.bigint "user_id"
    t.bigint "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_group_id", "user_id", "role_id"], name: "index_app_group_users_on_app_group_id_and_user_id_and_role_id", unique: true
    t.index ["app_group_id"], name: "index_app_group_users_on_app_group_id"
    t.index ["role_id"], name: "index_app_group_users_on_role_id"
    t.index ["user_id"], name: "index_app_group_users_on_user_id"
  end

  create_table "app_groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "log_count", default: 0
    t.string "secret_key"
    t.integer "log_retention_days", default: 30
    t.string "environment", default: "PRODUCTION"
    t.jsonb "labels", default: {}
    t.index ["name"], name: "index_app_groups_on_name"
    t.index ["secret_key"], name: "index_app_groups_on_secret_key"
  end

  create_table "barito_apps", force: :cascade do |t|
    t.string "name"
    t.string "secret_key"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "log_count", default: 0
    t.bigint "app_group_id"
    t.string "topic_name"
    t.integer "max_tps"
    t.integer "log_retention_days"
    t.bigint "latest_cost"
    t.bigint "latest_ingested_log_bytes"
    t.jsonb "labels", default: {}
    t.index ["app_group_id", "name"], name: "index_barito_apps_on_app_group_id_and_name", unique: true
    t.index ["app_group_id", "topic_name"], name: "index_barito_apps_on_app_group_id_and_topic_name", unique: true
    t.index ["app_group_id"], name: "index_barito_apps_on_app_group_id"
    t.index ["secret_key"], name: "index_barito_apps_on_secret_key"
    t.index ["status"], name: "index_barito_apps_on_status"
  end

  create_table "cluster_templates", force: :cascade do |t|
    t.string "name"
    t.jsonb "instances"
    t.jsonb "options"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "manifests", default: {}, null: false
    t.index ["name"], name: "index_cluster_templates_on_name", unique: true
  end

  create_table "component_templates", force: :cascade do |t|
    t.string "name"
    t.jsonb "bootstrappers"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "source"
    t.index ["name"], name: "index_component_templates_on_name", unique: true
  end

  create_table "deployment_templates", force: :cascade do |t|
    t.string "name"
    t.jsonb "bootstrappers"
    t.jsonb "source"
    t.index ["name"], name: "index_deployment_templates_on_name", unique: true
  end

  create_table "ext_apps", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "hashed_access_token", null: false
    t.datetime "access_token_generated_at", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_ext_apps_on_created_by_id"
    t.index ["hashed_access_token"], name: "index_ext_apps_on_hashed_access_token"
    t.index ["name"], name: "index_ext_apps_on_name", unique: true
  end

  create_table "group_users", force: :cascade do |t|
    t.bigint "group_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id"
    t.datetime "to_expire_on"
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_groups_on_name"
  end

  create_table "helm_cluster_templates", force: :cascade do |t|
    t.string "name", null: false
    t.jsonb "values", null: false
    t.integer "max_tps", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "helm_infrastructures", force: :cascade do |t|
    t.bigint "app_group_id", null: false
    t.bigint "helm_cluster_template_id", null: false
    t.jsonb "override_values", null: false
    t.text "last_log"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: false, null: false
    t.boolean "use_k8s_kibana", default: false, null: false
    t.string "cluster_name"
    t.string "status"
    t.string "provisioning_status"
    t.integer "max_tps"
    t.index ["app_group_id"], name: "index_helm_infrastructures_on_app_group_id"
    t.index ["helm_cluster_template_id"], name: "index_helm_infrastructures_on_helm_cluster_template_id"
  end

  create_table "infrastructure_components", force: :cascade do |t|
    t.string "hostname"
    t.string "component_type"
    t.integer "sequence"
    t.text "message"
    t.string "status"
    t.string "ipaddress"
    t.bigint "infrastructure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "bootstrappers", default: {}, null: false
    t.jsonb "source"
    t.index ["infrastructure_id"], name: "index_infrastructure_components_on_infrastructure_id"
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
    t.integer "cluster_template_id"
    t.jsonb "instances", default: {}, null: false
    t.jsonb "options", default: {}, null: false
    t.jsonb "manifests", default: {}, null: false
    t.index ["app_group_id"], name: "index_infrastructures_on_app_group_id"
    t.index ["cluster_template_id"], name: "index_infrastructures_on_cluster_template_id"
    t.index ["status"], name: "index_infrastructures_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: ""
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deactivated_at"
    t.index ["deactivated_at"], name: "index_users_on_deactivated_at"
    t.index ["email"], name: "index_users_on_email", unique: true, where: "((email IS NOT NULL) AND ((email)::text <> ''::text))"
    t.index ["username"], name: "index_users_on_username", unique: true, where: "((username IS NOT NULL) AND ((username)::text <> ''::text))"
  end

  add_foreign_key "app_group_bookmarks", "app_groups"
  add_foreign_key "app_group_bookmarks", "users"
  add_foreign_key "app_group_teams", "app_groups"
  add_foreign_key "app_group_teams", "groups"
  add_foreign_key "ext_apps", "users", column: "created_by_id"
  add_foreign_key "group_users", "app_group_roles", column: "role_id"
  add_foreign_key "helm_infrastructures", "app_groups"
  add_foreign_key "helm_infrastructures", "helm_cluster_templates"
  add_foreign_key "infrastructures", "cluster_templates"
end
