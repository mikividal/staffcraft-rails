class Analysis < ApplicationRecord
  belongs_to :user
  has_one :form_data, dependent: :destroy
  has_many :agent_results, dependent: :destroy

  enum status: {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3
  }

  enum recommended_approach: {
    full_hire: 0,
    automation_only: 1,
    hybrid_solution: 2,
    strategic_outsourcing: 3
  }

  validates :user, presence: true

  # Callbacks
  after_create :enqueue_analysis, :increment_user_count
  after_update :broadcast_progress_update, if: :saved_change_to_status?

  # Scopes
  scope :completed_today, -> { where(status: :completed, completed_at: Date.current.all_day) }
  scope :by_confidence, ->(level) { where('confidence_level >= ?', level) }
  scope :recent, -> { order(created_at: :desc) }

  def processing_time_seconds
    return nil unless completed_at && started_at
    (completed_at - started_at).to_i
  end

  def agents_completed
    agent_results.completed.count
  end

  def progress_percentage
    return 0 if pending?
    return 100 if completed?
    (agents_completed.to_f / 6 * 100).round(0)
  end

  def estimated_cost
    (total_tokens * 0.00003).round(4)
  end

  private

  def enqueue_analysis
    update!(started_at: Time.current)
    UltraPremiumAnalysisJob.perform_later(self)
  end

  def increment_user_count
    user.increment_daily_analysis!
  end

  def broadcast_progress_update
    AnalysisProgressChannel.broadcast_to(
      user,
      analysis_id: id,
      progress: progress_percentage,
      status: status,
      current_agent: current_agent_name
    )
  end
end
