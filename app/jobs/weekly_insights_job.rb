class WeeklyInsightsJob < ApplicationJob
  queue_as :mailers

  def perform
    User.joins(:analyses)
        .where(analyses: { created_at: 1.week.ago.. })
        .distinct
        .find_each do |user|

      insights = generate_user_insights(user)
      UserMailer.weekly_insights(user, insights).deliver_now
    end
  end

  private

  def generate_user_insights(user)
    analyses = user.analyses.where(created_at: 1.week.ago..)

    {
      analyses_count: analyses.count,
      success_rate: (analyses.completed.count.to_f / analyses.count * 100).round(1),
      most_common_approach: analyses.completed.group(:recommended_approach).count.max_by(&:last)&.first,
      total_tokens: analyses.sum(:total_tokens),
      insights: generate_personalized_insights(user, analyses)
    }
  end

  def generate_personalized_insights(user, analyses)
    [
      "You've completed #{analyses.completed.count} strategic analyses this week",
      "Your analyses show a preference for #{analyses.completed.group(:recommended_approach).count.max_by(&:last)&.first&.humanize} solutions",
      "Average confidence level: #{analyses.completed.average(:confidence_level)&.round(1)}%"
    ]
  end
end
