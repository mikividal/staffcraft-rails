FactoryBot.define do
  factory :agent_result do
    analysis { nil }
    agent_name { "MyString" }
    tokens_used { 1 }
    execution_time_ms { 1 }
    status { 1 }
    agent_output { "" }
    error_message { "MyText" }
    started_at { "2025-07-04 11:09:39" }
    completed_at { "2025-07-04 11:09:39" }
  end
end
