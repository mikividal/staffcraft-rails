class CleanupOldAnalysesJob < ApplicationJob
  queue_as :low

  def perform
    # Delete analyses older than 30 days
    old_analyses = Analysis.where('created_at < ?', 30.days.ago)
    count = old_analyses.count

    Rails.logger.info "Cleaning up #{count} old analyses"

    old_analyses.destroy_all

    Rails.logger.info "Cleanup completed"
  end
end
