class CreateAnalyses < ActiveRecord::Migration[7.1]
  def change
    create_table :analyses do |t|
      t.integer :status, default: 0
      t.integer :total_tokens, default: 0
      t.decimal :total_cost, precision: 8, scale: 4, default: 0.0
      t.json :final_results
      t.datetime :started_at
      t.datetime :completed_at
      t.text :error_message
      t.timestamps
    end

    add_index :analyses, :status
  end
end
