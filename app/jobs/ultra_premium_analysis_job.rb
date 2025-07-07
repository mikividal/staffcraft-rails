class UltraPremiumAnalysisJob < ApplicationJob
  queue_as :ultra_premium

  retry_on StandardError, wait: 30.seconds, attempts: 3

  def perform(analysis)
    Rails.logger.info "Starting Ultra Premium Analysis Job for Analysis ##{analysis.id}"

    orchestrator = AnalysisOrchestrator.new(analysis)
    result = orchestrator.execute_all_agents

    Rails.logger.info "Ultra Premium Analysis completed successfully for Analysis ##{analysis.id}"

  rescue => e
    Rails.logger.error "Ultra Premium Analysis Job failed for Analysis ##{analysis.id}: #{e.message}"

    analysis.update!(
      status: :failed,
      error_message: e.message,
      completed_at: Time.current
    )

    # Broadcast failure
    AnalysisProgressChannel.broadcast_to(
      analysis.user,
      status: 'failed',
      analysis_id: analysis.id,
      error: e.message
    )

    raise e
  end
end
