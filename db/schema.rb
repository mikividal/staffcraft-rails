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

ActiveRecord::Schema[7.1].define(version: 2025_08_01_122504) do
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
    t.string "company_name", null: false
    t.string "company_url"
    t.integer "industry_business_model"
    t.string "industry_other"
    t.integer "annual_revenue_band"
    t.integer "company_size"
    t.string "role_title", null: false
    t.integer "department_function"
    t.string "department_other"
    t.integer "seniority_level"
    t.integer "employment_type"
    t.integer "location_type"
    t.string "working_hours_timezone"
    t.string "onsite_location"
    t.text "must_have_skills"
    t.integer "monthly_budget_ceiling"
    t.text "preferred_compensation_model"
    t.string "compensation_other"
    t.string "contract_length"
    t.integer "deadline_to_fill"
    t.text "primary_pain_point"
    t.string "pain_point_other"
    t.text "desired_outcome"
    t.string "current_kpi_baseline"
    t.string "target_improvement"
    t.text "existing_tools_stack"
    t.text "existing_tools_custom"
    t.text "key_integrations"
    t.text "manual_tasks_friction"
    t.integer "tried_automating"
    t.text "main_data_formats"
    t.string "data_formats_other"
    t.text "regulatory_flags"
    t.string "regulatory_other"
    t.integer "data_residency_needs"
    t.text "security_requirements"
    t.string "security_other"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_internal_it_team", default: false
    t.string "team_skills_level"
    t.string "team_available_hours"
    t.text "existing_tools_data"
    t.index ["analysis_id"], name: "index_form_data_on_analysis_id"
    t.index ["annual_revenue_band"], name: "index_form_data_on_annual_revenue_band"
    t.index ["company_name"], name: "index_form_data_on_company_name"
    t.index ["company_size"], name: "index_form_data_on_company_size"
    t.index ["company_size"], name: "index_form_data_on_company_size_and_technical_maturity"
    t.index ["created_at"], name: "index_form_data_on_created_at"
    t.index ["deadline_to_fill"], name: "index_form_data_on_deadline_to_fill"
    t.index ["department_function", "seniority_level"], name: "index_form_data_on_department_function_and_seniority_level"
    t.index ["department_function"], name: "index_form_data_on_department_function"
    t.index ["employment_type"], name: "index_form_data_on_employment_type"
    t.index ["industry_business_model"], name: "index_form_data_on_industry_business_model"
    t.index ["location_type"], name: "index_form_data_on_location_type"
    t.index ["monthly_budget_ceiling", "deadline_to_fill"], name: "index_form_data_on_monthly_budget_ceiling_and_deadline_to_fill"
    t.index ["monthly_budget_ceiling"], name: "index_form_data_on_monthly_budget_ceiling"
    t.index ["role_title"], name: "index_form_data_on_role_title"
    t.index ["seniority_level"], name: "index_form_data_on_seniority_level"
  end

  add_foreign_key "agent_results", "analyses"
  add_foreign_key "form_data", "analyses"
end
