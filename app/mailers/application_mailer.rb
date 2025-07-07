class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@staffcraft.com'
  layout 'mailer'

  private

  def track_email(event_type, user = nil, data = {})
    AnalyticsEvent.track(
      event_type,
      user: user,
      data: data.merge(
        email_type: self.class.name,
        email_action: action_name
      )
    )
  end
end
