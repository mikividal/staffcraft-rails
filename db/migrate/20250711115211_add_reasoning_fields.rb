# db/migrate/005_add_reasoning_fields.rb
class AddReasoningFields < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_results, :reasoning_chain, :json
    add_column :agent_results, :reasoning_confidence, :string
    add_column :analyses, :critic_review, :json
    add_column :analyses, :reasoning_validated, :boolean, default: false

    add_index :analyses, :reasoning_validated
  end
end
