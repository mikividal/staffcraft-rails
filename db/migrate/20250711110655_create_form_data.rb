class CreateFormData < ActiveRecord::Migration[7.1]
  def change
    create_table :form_data do |t|
      t.references :analysis, null: false, foreign_key: true
      t.text :process_description
      t.string :business_type
      t.string :role_type
      t.string :experience_level
      t.text :key_skills
      t.string :budget_range
      t.string :country
      t.string :team_size
      t.string :technical_expertise
      t.text :current_stack
      t.text :constraints
      t.string :timeline
      t.timestamps
    end
  end
end
