class CacheService
  CACHE_EXPIRY = {
    user_metrics: 1.hour,
    analysis_results: 24.hours,
    system_health: 5.minutes,
    daily_metrics: 1.hour
  }.freeze

  def self.fetch(key, expires_in: 1.hour, &block)
    Rails.cache.fetch(cache_key(key), expires_in: expires_in, &block)
  end

  def self.write(key, value, expires_in: 1.hour)
    Rails.cache.write(cache_key(key), value, expires_in: expires_in)
  end

  def self.delete(key)
    Rails.cache.delete(cache_key(key))
  end

  def self.user_metrics(user_id)
    fetch("user_metrics:#{user_id}", expires_in: CACHE_EXPIRY[:user_metrics]) do
      user = User.find(user_id)
      AnalyticsService.user_metrics(user)
    end
  end

  def self.analysis_results(analysis_id)
    fetch("analysis_results:#{analysis_id}", expires_in: CACHE_EXPIRY[:analysis_results]) do
      analysis = Analysis.includes(:form_data, :agent_results).find(analysis_id)
      AnalysisSerializer.new(analysis, include_results: true).serialized_json
    end
  end

  def self.daily_metrics(date = Date.current)
    fetch("daily_metrics:#{date}", expires_in: CACHE_EXPIRY[:daily_metrics]) do
      AnalyticsService.daily_metrics(date)
    end
  end

  private

  def self.cache_key(key)
    "staffcraft:#{Rails.env}:#{key}"
  end
end
