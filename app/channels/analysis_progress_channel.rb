class AnalysisProgressChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
    Rails.logger.info "User #{current_user.id} subscribed to analysis progress"
  end

  def unsubscribed
    Rails.logger.info "User #{current_user.id} unsubscribed from analysis progress"
  end
end
