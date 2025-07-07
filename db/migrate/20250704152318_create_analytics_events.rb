class CreateAnalyticsEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :analytics_events do |t|
      t.references :user, foreign_key: true, null: true
      t.references :analysis, foreign_key: true, null: true
      t.integer :event_type, null: false
      t.json :event_data, null: false
      t.string :ip_address
      t.text :user_agent
      t.timestamps
    end

    add_index :analytics_events, [:event_type, :created_at]
    add_index :analytics_events, :created_at
  end
end
