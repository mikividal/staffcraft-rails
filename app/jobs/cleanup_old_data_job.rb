class CleanupOldDataJob < ApplicationJob
  queue_as :maintenance

  def perform
    cleanup_old_analytics_events
    cleanup_failed_analyses
    cleanup_orphaned_agent_results
  end

  private

  def cleanup_old_analytics_events
    # Keep analytics events for 90 days
    AnalyticsEvent.where('created_at < ?', 90.days.ago).delete_all
    Rails.logger.info "Cleaned up old analytics events"
  end

  def cleanup_failed_analyses
    # Remove failed analyses older than 30 days (keep form data for debugging)
    Analysis.failed.where('created_at < ?', 30.days.ago).destroy_all
    Rails.logger.info "Cleaned up old failed analyses"
  end

  def cleanup_orphaned_agent_results
    # Remove agent results without parent analysis
    orphaned_count = AgentResult.left_joins(:analysis).where(analyses: { id: nil }).delete_all
    Rails.logger.info "Cleaned up #{orphaned_count} orphaned agent results"
  end
end
