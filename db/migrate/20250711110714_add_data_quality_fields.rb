class AddDataQualityFields < ActiveRecord::Migration[7.1]
  def change
    add_column :agent_results, :data_quality, :json
    add_column :agent_results, :validation_status, :string

    add_index :agent_results, :validation_status
  end
end
