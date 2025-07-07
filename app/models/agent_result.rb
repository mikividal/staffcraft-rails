class AgentResult < ApplicationRecord
  belongs_to :analysis
  enum status: { pending: 0, running: 1, completed: 2, failed: 3 }

  validates :agent_name, presence: true

  scope :successful, -> { where(status: :completed) }
  scope :by_execution_order, -> { order(:created_at) }
end
