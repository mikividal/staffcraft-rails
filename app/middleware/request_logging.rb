class RequestLogging
  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    start_time = Time.current

    status, headers, response = @app.call(env)

    end_time = Time.current
    duration_ms = ((end_time - start_time) * 1000).round(2)

    log_request(request, status, duration_ms)

    [status, headers, response]
  end

  private

  def log_request(request, status, duration_ms)
    return unless request.path.start_with?('/api/')

    log_data = {
      method: request.method,
      path: request.path,
      status: status,
      duration_ms: duration_ms,
      ip: request.remote_ip,
      user_agent: request.user_agent,
      request_id: request.request_id
    }

    Rails.logger.info "API Request: #{log_data.to_json}"

    # Track slow requests
    if duration_ms > 5000 # 5 seconds
      AnalyticsEvent.track(
        :performance_metric,
        data: log_data.merge(type: 'slow_request')
      )
    end
  end
end
