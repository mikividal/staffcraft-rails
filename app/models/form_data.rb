# app/models/form_data.rb
class FormData < ApplicationRecord
  belongs_to :analysis

  validates :process_description, :business_type, :role_type, presence: true

  def to_context_hash
    attributes.except('id', 'analysis_id', 'created_at', 'updated_at').compact
  end
end
