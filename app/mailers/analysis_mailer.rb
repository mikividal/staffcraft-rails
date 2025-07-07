class AnalysisMailer < ApplicationMailer
  def analysis_completed(analysis)
    @analysis = analysis
    @user = analysis.user

    track_email(:analysis_completed, @user, { analysis_id: analysis.id })

    mail(
      to: @user.email,
      subject: "Your StaffCraft Analysis is Ready! (#{@analysis.recommended_approach.humanize})"
    )
  end

  def analysis_failed(analysis)
    @analysis = analysis
    @user = analysis.user

    track_email(:analysis_failed, @user, { analysis_id: analysis.id })

    mail(
      to: @user.email,
      subject: "StaffCraft Analysis - Issue Encountered"
    )
  end

  def weekly_insights(user, insights)
    @user = user
    @insights = insights

    track_email(:weekly_insights, @user)

    mail(
      to: @user.email,
      subject: "Your Weekly StaffCraft Insights"
    )
  end
end
