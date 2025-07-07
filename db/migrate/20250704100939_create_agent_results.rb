class CreateAgentResults < ActiveRecord::Migration[7.1]
  def change
    create_table :agent_results do |t|
      t.references :analysis, null: false, foreign_key: true
      t.string :agent_name, null: false
      t.integer :tokens_used, default: 0
      t.integer :execution_time_ms, default: 0
      t.integer :status, default: 0 # pending, running, completed, failed
      t.json :agent_output
      t.text :error_message
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :agent_results, [:analysis_id, :agent_name]
  end
end
