# config/initializers/sidekiq.rb
require 'sidekiq'
require 'sidekiq/web'

# Configure Sidekiq server
Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    network_timeout: 5
  }

  # Error handling
  config.error_handlers << Proc.new do |exception, context_hash|
    Rails.logger.error "Sidekiq error: #{exception.class.name}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
  end

  # Death handlers for jobs that exhausted retries
  config.death_handlers << Proc.new do |job, exception|
    Rails.logger.error "Job died: #{job['class']} - #{job['jid']}"

    # Mark analysis as failed if it's an AnalysisJob
    if job['class'] == 'AnalysisJob' && job['args'].first
      Analysis.find_by(id: job['args'].first)&.update(
        status: :failed,
        error_message: "Job failed after multiple retries: #{exception.message}"
      )
    end
  end
end

# Configure Sidekiq client
Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
    network_timeout: 5
  }
end

# Configure Sidekiq Web UI
Sidekiq::Web.use ActionDispatch::Cookies
Sidekiq::Web.use ActionDispatch::Session::CookieStore, key: "_staffcraft_session"

# Basic auth for Sidekiq Web in production
if Rails.env.production?
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(username, ENV['SIDEKIQ_USERNAME']) &
    ActiveSupport::SecurityUtils.secure_compare(password, ENV['SIDEKIQ_PASSWORD'])
  end
end
