class AnalyticsEvent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :analysis, optional: true

  validates :event_type, :event_data, presence: true

  enum event_type: {
    user_registered: 0,
    analysis_started: 1,
    analysis_completed: 2,
    analysis_failed: 3,
    user_upgraded: 4,
    agent_executed: 5,
    api_error: 6,
    performance_metric: 7
  }

  scope :recent, -> { where(created_at: 1.week.ago..) }
  scope :by_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }

  def self.track(event_type, user: nil, analysis: nil, data: {})
    create!(
      event_type: event_type,
      user: user,
      analysis: analysis,
      event_data: data.merge(timestamp: Time.current.iso8601),
      ip_address: Current.ip_address,
      user_agent: Current.user_agent
    )
  end
end
