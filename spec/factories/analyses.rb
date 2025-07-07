FactoryBot.define do
  factory :analysis do
    user { nil }
    status { 1 }
    total_tokens { 1 }
    total_cost { "9.99" }
    confidence_level { 1 }
    recommended_approach { 1 }
    current_agent_name { "MyString" }
    error_message { "MyText" }
    started_at { "2025-07-04 11:07:41" }
    completed_at { "2025-07-04 11:07:41" }
    final_results { "" }
  end
end
