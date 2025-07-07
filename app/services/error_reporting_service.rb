class ErrorReportingService
  def self.report(exception, context = {})
    error_data = {
      class: exception.class.name,
      message: exception.message,
      backtrace: exception.backtrace&.first(20),
      context: context,
      timestamp: Time.current.iso8601,
      environment: Rails.env
    }

    # Log locally
    Rails.logger.error "Error Report: #{error_data.to_json}"

    # Send to external service (Sentry, Bugsnag, etc.)
    if Rails.env.production?
      send_to_external_service(error_data)
    end
  end

  private

  def self.send_to_external_service(error_data)
    # Integration with external error tracking service
    # This would typically use Sentry, Bugsnag, or similar
    begin
      # Example: Sentry.capture_exception(exception, extra: error_data)
    rescue => e
      Rails.logger.error "Failed to send error to external service: #{e.message}"
    end
  end
end
