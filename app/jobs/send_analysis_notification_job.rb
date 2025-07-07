class SendAnalysisNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(analysis_id, notification_type = 'completed')
    analysis = Analysis.find(analysis_id)

    case notification_type
    when 'completed'
      AnalysisMailer.analysis_completed(analysis).deliver_now
    when 'failed'
      AnalysisMailer.analysis_failed(analysis).deliver_now
    end

    AnalyticsEvent.track(
      :email_sent,
      user: analysis.user,
      analysis: analysis,
      data: { notification_type: notification_type }
    )
  end
end
