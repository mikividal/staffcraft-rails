class AnalysisJob < ApplicationJob
  queue_as :default

  # Retry with exponential backoff
  retry_on StandardError, wait: :exponentially_longer, attempts: 3 do |job, error|
    # Log the retry
    Rails.logger.error "AnalysisJob retry #{job.executions} for analysis #{job.arguments.first}: #{error.message}"

    # Update analysis with retry information
    analysis = Analysis.find_by(id: job.arguments.first)
    if analysis && job.executions >= 3
      analysis.update(
        status: :failed,
        error_message: "Failed after 3 attempts: #{error.message}"
      )
    end
  end

  # Don't retry on these errors
  discard_on ActiveRecord::RecordNotFound do |job, error|
    Rails.logger.error "Analysis not found: #{job.arguments.first}"
  end

  def perform(analysis_id)
    analysis = Analysis.find(analysis_id)

    Rails.logger.info "Starting AnalysisJob for analysis ##{analysis.id}"

    # Create orchestrator and execute
    orchestrator = AnalysisOrchestrator.new(analysis)
    orchestrator.execute

    Rails.logger.info "Completed AnalysisJob for analysis ##{analysis.id}"
  rescue => e
    Rails.logger.error "AnalysisJob failed for analysis ##{analysis_id}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise # Re-raise to trigger retry
  end
end
