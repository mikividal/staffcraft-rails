class CreateFormData < ActiveRecord::Migration[7.1]
  def change
    create_table :form_data do |t|
      # Foreign key
      t.references :analysis, null: false, foreign_key: true

      # ================================
      # 1. COMPANY SNAPSHOT
      # ================================
      t.string :company_name, null: false
      t.string :company_url
      t.integer :industry_business_model             # enum dropdown (single-select)
      t.string :industry_other                       # "Other" text field
      t.integer :annual_revenue_band                 # enum dropdown
      t.integer :company_size                        # enum dropdown
      t.integer :technical_maturity                  # enum dropdown

      # ================================
      # 2. ROLE TO HIRE
      # ================================
      t.string :role_title, null: false
      t.integer :department_function                 # enum dropdown
      t.string :department_other                     # "Other" text field
      t.integer :seniority_level                     # enum dropdown
      t.integer :employment_type                     # enum dropdown
      t.integer :location_type                       # enum dropdown
      t.string :working_hours_timezone               # string dropdown/select
      t.string :onsite_location                      # string (cities autocomplete)
      t.text :must_have_skills                       # serialized array (tag list with predefined skills + other)
      t.integer :monthly_budget_ceiling              # enum dropdown
      t.text :preferred_compensation_model           # serialized array (multi-select checkboxes)
      t.string :compensation_other                   # "Other" text field
      t.string :contract_length                      # text input
      t.integer :deadline_to_fill                    # enum dropdown

      # ================================
      # 3. PAIN POINT & GOALS
      # ================================
      t.text :primary_pain_point                     # serialized array (multi-select)
      t.string :pain_point_other                     # "Other" text field
      t.text :desired_outcome                        # text area
      t.string :current_kpi_baseline                 # text input
      t.string :target_improvement                   # text input

      # ================================
      # 4. TOOLS & PROCESS CONTEXT
      # ================================
      t.text :existing_tools_stack                   # serialized array (checkboxes from predefined list)
      t.text :existing_tools_custom                  # text area (free text for additional tools)
      t.text :key_integrations                       # serialized array (tag list with predefined integrations)
      t.text :manual_tasks_friction                  # text area
      t.integer :tried_automating                    # enum dropdown
      t.text :main_data_formats                      # serialized array (multi-select)
      t.string :data_formats_other                   # "Other" text field

      # ================================
      # 5. CONSTRAINTS & COMPLIANCE
      # ================================
      t.text :regulatory_flags                       # serialized array (multi-select)
      t.string :regulatory_other                     # "Other" text field
      t.integer :data_residency_needs                # enum dropdown
      t.text :security_requirements                  # serialized array (multi-select)
      t.string :security_other                       # "Other" text field

      t.timestamps
    end

    # ================================
    # INDEXES FOR PERFORMANCE
    # ================================

    # Critical indexes (always needed)
    add_index :form_data, :created_at               # Date ordering

    # Search and filter indexes
    add_index :form_data, :company_name             # Company searches
    add_index :form_data, :role_title               # Role searches

    # Analytics and reporting indexes
    add_index :form_data, :department_function      # Department filtering
    add_index :form_data, :industry_business_model  # Industry filtering
    add_index :form_data, :annual_revenue_band      # Revenue analytics
    add_index :form_data, :company_size             # Size segmentation
    add_index :form_data, :technical_maturity       # Technical capability analysis
    add_index :form_data, :monthly_budget_ceiling   # Budget analytics
    add_index :form_data, :deadline_to_fill         # Urgency analysis
    add_index :form_data, :seniority_level          # Experience level filtering
    add_index :form_data, :employment_type          # Employment type analytics
    add_index :form_data, :location_type            # Location preference analytics

    # Composite indexes for common query patterns
    add_index :form_data, [:department_function, :seniority_level]     # Role + experience filtering
    add_index :form_data, [:company_size, :technical_maturity]         # Company profile analysis
    add_index :form_data, [:monthly_budget_ceiling, :deadline_to_fill] # Budget + urgency analysis
  end
end
