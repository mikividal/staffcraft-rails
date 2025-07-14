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

ActiveRecord::Schema[7.1].define(version: 2025_07_11_115211) do
  create_table "agent_results", force: :cascade do |t|
    t.integer "analysis_id", null: false
    t.string "agent_name", null: false
    t.integer "tokens_used", default: 0
    t.integer "execution_time_ms", default: 0
    t.integer "status", default: 0
    t.json "agent_output"
    t.json "data_sources"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "data_quality"
    t.string "validation_status"
    t.json "reasoning_chain"
    t.string "reasoning_confidence"
    t.index ["analysis_id", "agent_name"], name: "index_agent_results_on_analysis_id_and_agent_name"
    t.index ["analysis_id"], name: "index_agent_results_on_analysis_id"
    t.index ["validation_status"], name: "index_agent_results_on_validation_status"
  end

  create_table "analyses", force: :cascade do |t|
    t.integer "status", default: 0
    t.integer "total_tokens", default: 0
    t.decimal "total_cost", precision: 8, scale: 4, default: "0.0"
    t.json "final_results"
    t.datetime "started_at"
    t.datetime "completed_at"
    t.text "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "critic_review"
    t.boolean "reasoning_validated", default: false
    t.index ["reasoning_validated"], name: "index_analyses_on_reasoning_validated"
    t.index ["status"], name: "index_analyses_on_status"
  end

  create_table "form_data", force: :cascade do |t|
    t.integer "analysis_id", null: false
    t.text "process_description"
    t.string "business_type"
    t.string "role_type"
    t.string "experience_level"
    t.text "key_skills"
    t.string "budget_range"
    t.string "country"
    t.string "team_size"
    t.string "technical_expertise"
    t.text "current_stack"
    t.text "constraints"
    t.string "timeline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["analysis_id"], name: "index_form_data_on_analysis_id"
  end

  add_foreign_key "agent_results", "analyses"
  add_foreign_key "form_data", "analyses"
end
