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

ActiveRecord::Schema[7.1].define(version: 2025_07_04_152318) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agent_results", force: :cascade do |t|
    t.bigint "analysis_id", null: false
    t.string "agent_name", null: false
    t.integer "tokens_used", default: 0
    t.integer "execution_time_ms", default: 0
    t.integer "status", default: 0
    t.json "agent_output"
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id", "agent_name"], name: "index_agent_results_on_analysis_id_and_agent_name"
    t.index ["analysis_id"], name: "index_agent_results_on_analysis_id"
  end

  create_table "analyses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status", default: 0
    t.integer "total_tokens", default: 0
    t.decimal "total_cost", precision: 8, scale: 4, default: "0.0"
    t.integer "confidence_level", default: 0
    t.integer "recommended_approach", default: 0
    t.string "current_agent_name"
    t.text "error_message"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.json "final_results"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_analyses_on_status"
    t.index ["user_id", "created_at"], name: "index_analyses_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_analyses_on_user_id"
  end

  create_table "analytics_events", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "analysis_id"
    t.integer "event_type", null: false
    t.json "event_data", null: false
    t.string "ip_address"
    t.text "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_analytics_events_on_analysis_id"
    t.index ["created_at"], name: "index_analytics_events_on_created_at"
    t.index ["event_type", "created_at"], name: "index_analytics_events_on_event_type_and_created_at"
    t.index ["user_id"], name: "index_analytics_events_on_user_id"
  end

  create_table "form_data", force: :cascade do |t|
    t.bigint "analysis_id", null: false
    t.text "process_description"
    t.string "business_type"
    t.string "company_website"
    t.text "current_challenges"
    t.string "role_type"
    t.string "experience_level"
    t.text "key_skills"
    t.string "budget_range"
    t.string "work_arrangement"
    t.text "expected_outcome"
    t.text "kpis"
    t.text "programming_languages"
    t.text "programming_subscriptions"
    t.text "databases"
    t.text "database_subscriptions"
    t.text "cloud_providers"
    t.text "cloud_subscriptions"
    t.text "ai_tools"
    t.text "ai_subscriptions"
    t.string "team_size"
    t.string "technical_expertise"
    t.string "automation_level"
    t.text "process_volume"
    t.text "peak_times"
    t.text "integration_requirements"
    t.string "it_team_availability"
    t.string "implementation_capacity"
    t.text "internal_skills_available"
    t.string "maintenance_capability"
    t.string "change_management_capacity"
    t.text "operational_constraints"
    t.string "country"
    t.string "timeline"
    t.text "security_requirements"
    t.text "additional_context"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_form_data_on_analysis_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.string "company_name"
    t.integer "tier"
    t.integer "daily_analysis_count"
    t.date "last_analysis_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "agent_results", "analyses"
  add_foreign_key "analyses", "users"
  add_foreign_key "analytics_events", "analyses"
  add_foreign_key "analytics_events", "users"
  add_foreign_key "form_data", "analyses"
end
