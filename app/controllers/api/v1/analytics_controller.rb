class Api::V1::AnalyticsController < ApplicationController
  before_action :ensure_admin, except: [:user_metrics]

  def dashboard
    render json: {
      daily_metrics: AnalyticsService.daily_metrics,
      system_health: AnalyticsService.system_health,
      recent_activity: recent_activity
    }
  end

  def user_metrics
    metrics = AnalyticsService.user_metrics(current_user)
    render json: metrics
  end

  def historical
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    metrics = (start_date..end_date).map do |date|
      AnalyticsService.daily_metrics(date)
    end

    render json: metrics
  end

  private

  def ensure_admin
    render json: { error: 'Admin access required' }, status: :forbidden unless current_user&.admin?
  end

  def recent_activity
    AnalyticsEvent.recent.limit(50).order(created_at: :desc)
  end
end
