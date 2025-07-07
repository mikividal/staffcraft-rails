class CreateFormData < ActiveRecord::Migration[7.1]
  def change
    create_table :form_data do |t|
      t.references :analysis, null: false, foreign_key: true
      t.text :process_description
      t.string :business_type
      t.string :company_website
      t.text :current_challenges
      t.string :role_type
      t.string :experience_level
      t.text :key_skills
      t.string :budget_range
      t.string :work_arrangement
      t.text :expected_outcome
      t.text :kpis
      t.text :programming_languages
      t.text :programming_subscriptions
      t.text :databases
      t.text :database_subscriptions
      t.text :cloud_providers
      t.text :cloud_subscriptions
      t.text :ai_tools
      t.text :ai_subscriptions
      t.string :team_size
      t.string :technical_expertise
      t.string :automation_level
      t.text :process_volume
      t.text :peak_times
      t.text :integration_requirements
      t.string :it_team_availability
      t.string :implementation_capacity
      t.text :internal_skills_available
      t.string :maintenance_capability
      t.string :change_management_capacity
      t.text :operational_constraints
      t.string :country
      t.string :timeline
      t.text :security_requirements
      t.text :additional_context

      t.timestamps
    end
  end
end
