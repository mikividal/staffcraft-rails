class CreateAnalyses < ActiveRecord::Migration[7.1]
  def change
    create_table :analyses do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0 # pending, processing, completed, failed
      t.integer :total_tokens, default: 0
      t.decimal :total_cost, precision: 8, scale: 4, default: 0.0
      t.integer :confidence_level, default: 0
      t.integer :recommended_approach, default: 0
      t.string :current_agent_name
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at
      t.json :final_results

      t.timestamps
    end

    add_index :analyses, [:user_id, :created_at]
    add_index :analyses, :status
  end
end
