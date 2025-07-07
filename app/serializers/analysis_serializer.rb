 app/serializers/analysis_serializer.rb
class AnalysisSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :status, :total_tokens, :total_cost, :confidence_level,
             :recommended_approach, :created_at, :completed_at

  belongs_to :user
  has_one :form_data
  has_many :agent_results

  attribute :processing_time_seconds do |analysis|
    analysis.processing_time_seconds
  end

  attribute :progress_percentage do |analysis|
    analysis.progress_percentage
  end

  attribute :estimated_cost do |analysis|
    analysis.estimated_cost
  end

  attribute :final_results, if: Proc.new { |record, params|
    params[:include_results] && record.completed?
  }
end
