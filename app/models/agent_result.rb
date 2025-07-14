class AgentResult < ApplicationRecord
  belongs_to :analysis

  enum status: { pending: 0, running: 1, completed: 2, failed: 3 }

  def high_confidence?
    data_sources&.dig('data_quality', 'confidence') == 'high'
  end

  def has_missing_data?
    data_sources&.dig('data_quality', 'missing_data')&.any?
  end

  def source_types
    data_sources&.dig('data_quality', 'sources') || []
  end

  def from_web_search?
    data_sources&.dig('searches')&.any?
  end

  def from_claude_knowledge?
    data_sources&.dig('data_quality', 'source') == 'claude_knowledge'
  end

  def reasoning_steps
    reasoning_chain&.dig('steps') || []
  end

  def reasoning_valid?
    reasoning_confidence == 'validated'
  end
end
