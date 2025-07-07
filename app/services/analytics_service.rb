class AnalyticsService
  def self.daily_metrics(date = Date.current)
    {
      date: date,
      new_users: User.where(created_at: date.all_day).count,
      total_analyses: Analysis.where(created_at: date.all_day).count,
      completed_analyses: Analysis.where(completed_at: date.all_day).count,
      failed_analyses: Analysis.where(status: :failed, updated_at: date.all_day).count,
      total_tokens: Analysis.where(completed_at: date.all_day).sum(:total_tokens),
      total_revenue: calculate_daily_revenue(date),
      avg_processing_time: average_processing_time(date),
      agent_performance: agent_performance_metrics(date)
    }
  end

  def self.user_metrics(user, period = 30.days)
    analyses = user.analyses.where(created_at: period.ago..)

    {
      total_analyses: analyses.count,
      completed_analyses: analyses.completed.count,
      success_rate: (analyses.completed.count.to_f / analyses.count * 100).round(2),
      total_tokens: analyses.sum(:total_tokens),
      total_cost: analyses.sum(:total_cost),
      avg_confidence: analyses.completed.average(:confidence_level)&.round(2),
      most_common_approach: most_common_approach(analyses),
      usage_trend: usage_trend(user, period)
    }
  end

  def self.system_health
    {
      database_status: database_healthy?,
      redis_status: redis_healthy?,
      sidekiq_status: sidekiq_healthy?,
      claude_api_status: claude_api_healthy?,
      recent_errors: recent_error_count,
      avg_response_time: average_response_time,
      queue_length: Sidekiq::Queue.new.size
    }
  end

  private

  def self.calculate_daily_revenue(date)
    # Simplified revenue calculation
    free_users = User.free.joins(:analyses).where(analyses: { created_at: date.all_day }).distinct.count
    premium_users = User.premium.joins(:analyses).where(analyses: { created_at: date.all_day }).distinct.count
    enterprise_users = User.enterprise.joins(:analyses).where(analyses: { created_at: date.all_day }).distinct.count

    (premium_users * 29.99 / 30) + (enterprise_users * 99.99 / 30)
  end

  def self.average_processing_time(date)
    Analysis.where(completed_at: date.all_day)
           .where.not(started_at: nil)
           .average('EXTRACT(EPOCH FROM (completed_at - started_at))')
           &.round(2)
  end

  def self.agent_performance_metrics(date)
    agent_results = AgentResult.joins(:analysis)
                              .where(analyses: { completed_at: date.all_day })

    agent_results.group(:agent_name).group(:status).count
  end

  def self.most_common_approach(analyses)
    analyses.completed.group(:recommended_approach).count.max_by(&:last)&.first
  end

  def self.usage_trend(user, period)
    user.analyses.where(created_at: period.ago..)
        .group_by_day(:created_at)
        .count
  end

  def self.database_healthy?
    ActiveRecord::Base.connection.execute('SELECT 1').any?
  rescue
    false
  end

  def self.redis_healthy?
    Redis.new(url: ENV['REDIS_URL']).ping == 'PONG'
  rescue
    false
  end

  def self.sidekiq_healthy?
    Sidekiq.redis(&:ping) == 'PONG'
  rescue
    false
  end

  def self.claude_api_healthy?
    # Simple health check - could be more sophisticated
    ClaudeClient.new.complete(prompt: 'Hello', max_tokens: 10)
    true
  rescue
    false
  end

  def self.recent_error_count
    AnalyticsEvent.api_error.where(created_at: 1.hour.ago..).count
  end

  def self.average_response_time
    # This would need to be implemented with request tracking
    # For now, return a placeholder
    0.0
  end
end
