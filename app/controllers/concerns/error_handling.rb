module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
    rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized
    rescue_from JWT::DecodeError, with: :handle_jwt_error
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error "Unhandled error: #{exception.class}: #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    AnalyticsEvent.track(
      :api_error,
      user: current_user,
      data: {
        error_class: exception.class.name,
        error_message: exception.message,
        controller: controller_name,
        action: action_name,
        request_id: request.request_id
      }
    )

    if Rails.env.production?
      render json: { error: 'Internal server error' }, status: :internal_server_error
    else
      render json: {
        error: exception.message,
        backtrace: exception.backtrace.first(10)
      }, status: :internal_server_error
    end
  end

  def handle_not_found(exception)
    render json: { error: 'Resource not found' }, status: :not_found
  end

  def handle_invalid_record(exception)
    render json: {
      error: 'Validation failed',
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def handle_unauthorized(exception)
    render json: { error: 'Access denied' }, status: :forbidden
  end

  def handle_jwt_error(exception)
    render json: { error: 'Invalid authentication token' }, status: :unauthorized
  end
end
