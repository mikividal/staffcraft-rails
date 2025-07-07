class FormDatum < ApplicationRecord
  belongs_to :analysis

  validates :process_description, :business_type, :country, presence: true
  validates :process_description, length: { minimum: 10 }

  def completeness_score
    total_fields = self.class.column_names.count - 3 # exclude id, analysis_id, timestamps
    completed_fields = attributes.values.count { |v| v.present? }
    ((completed_fields.to_f / total_fields) * 100).round(0)
  end

  def to_context_hash
    attributes.except('id', 'analysis_id', 'created_at', 'updated_at')
              .compact
              .transform_values { |v| v.presence || 'Not provided' }
  end
end
