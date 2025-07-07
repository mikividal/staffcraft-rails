FactoryBot.define do
  factory :analytics_event do
    user { nil }
    analysis { nil }
    event_type { 1 }
    event_data { "" }
    ip_address { "MyString" }
    user_agent { "MyText" }
  end
end
