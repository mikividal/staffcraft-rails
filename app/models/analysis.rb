class Analysis < ApplicationRecord
  has_one :form_data, dependent: :destroy
  has_many :agent_results, dependent: :destroy
  accepts_nested_attributes_for :form_data

  enum status: {
    pending: 0,
    processing: 1,
    validating: 2,  # New status for critic review
    completed: 3,
    failed: 4
  }

  after_create :enqueue_analysis

  def agents_completed
    agent_results.where(status: 'completed').count
  end

  def agents_failed
    agent_results.where(status: 'failed').count
  end

  def progress_percentage
    return 0 if pending?
    return 100 if completed? || failed?

    total_agents = 7  # Now includes critic agent
    completed = agents_completed
    failed = agents_failed

    ((completed + failed).to_f / total_agents * 100).round(0)
  end

  def data_quality_summary
    return {} unless completed?

    final_results&.dig('data_transparency', 'quality_summary') || {}
  end

  def has_low_confidence_data?
    data_quality_summary['low_confidence']&.any? ||
    data_quality_summary['failed_agents']&.any?
  end

  def has_reasoning_issues?
    critic_review&.dig('reasoning_issues')&.any?
  end

  def reasoning_chains
    agent_results.where.not(reasoning_chain: nil).pluck(:agent_name, :reasoning_chain)
  end

  def full_context_for_ai
    return {} unless form_data.present?

      {
        analysis_id: id,
        status: status,
        form_context: form_data.to_context_hash,
        created_at: created_at,
        progress: progress_percentage
      }
  end

    # Para verificar si tiene toda la info necesaria
  def ready_for_ai_analysis?
    form_data.present? &&
    form_data.company_name.present? &&
    form_data.role_title.present?
  end

  private

  def enqueue_analysis
    AnalysisJob.perform_later(self.id)
  end
end
