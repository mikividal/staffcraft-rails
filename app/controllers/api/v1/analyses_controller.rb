class Api::V1::AnalysesController < ApplicationController
  before_action :check_rate_limit, only: [:create]
  before_action :set_analysis, only: [:show, :destroy]

  def index
    analyses = current_user.analyses
                          .includes(:form_data, :agent_results)
                          .recent
                          .page(params[:page])
                          .per(10)

    render json: AnalysisSerializer.new(analyses).serialized_json
  end

 def show
    # Use cached result if available
    cached_result = CacheService.analysis_results(@analysis.id)

    if cached_result && @analysis.completed?
      render json: cached_result
    else
      result = AnalysisSerializer.new(@analysis, include_results: true).serialized_json

      # Cache completed analyses
      if @analysis.completed?
        CacheService.write("analysis_results:#{@analysis.id}", result, expires_in: 24.hours)
      end

      render json: result
    end
  end

  def create
    form_data_attrs = form_data_params

    # Validate form data
    validator = FormDataValidator.new
    validation_result = validator.call(form_data_attrs)

    unless validation_result.success?
      return render json: {
        errors: validation_result.errors.to_h
      }, status: :unprocessable_entity
    end

    # Create analysis and form data
    analysis = current_user.analyses.create!(status: :pending)
    analysis.create_form_data!(form_data_attrs)

    render json: {
      analysis_id: analysis.id,
      status: 'processing',
      estimated_time: '2-3 minutes',
      progress_url: "/api/v1/analyses/#{analysis.id}",
      websocket_channel: "analysis_progress_#{current_user.id}"
    }, status: :created

  rescue ActiveRecord::RecordInvalid => e
    render json: {
      errors: e.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def destroy
    @analysis.destroy
    head :no_content
  end

  private

  def set_analysis
    @analysis = current_user.analyses.find(params[:id])
  end

  def form_data_params
    params.require(:form_data).permit(
      :process_description, :business_type, :company_website,
      :current_challenges, :role_type, :experience_level,
      :key_skills, :budget_range, :work_arrangement,
      :expected_outcome, :kpis,
      :programming_languages, :programming_subscriptions,
      :databases, :database_subscriptions,
      :cloud_providers, :cloud_subscriptions,
      :ai_tools, :ai_subscriptions,
      :team_size, :technical_expertise, :automation_level,
      :process_volume, :peak_times, :integration_requirements,
      :it_team_availability, :implementation_capacity,
      :internal_skills_available, :maintenance_capability,
      :change_management_capacity, :operational_constraints,
      :country, :timeline, :security_requirements, :additional_context
    )
  end

  def check_rate_limit
    unless current_user.can_create_analysis?
      limit = current_user.free? ? 1 : (current_user.premium? ? 10 : 'unlimited')

      render json: {
        error: "Daily analysis limit reached (#{limit} for #{current_user.tier} users)",
        upgrade_url: '/upgrade'
      }, status: :too_many_requests
    end
  end
end
