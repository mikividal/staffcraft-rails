every 1.week, at: '9:00 am' do
  runner "WeeklyInsightsJob.perform_later"
end

every 1.day, at: '2:00 am' do
  runner "CleanupOldDataJob.perform_later"
end

every 1.hour do
  runner "AnalyticsEvent.track(:system_health, data: AnalyticsService.system_health)"
end
