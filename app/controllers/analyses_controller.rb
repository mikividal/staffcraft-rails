# app/controllers/analyses_controller.rb
# app/controllers/analyses_controller.rb
class AnalysesController < ApplicationController
  def new
    @analysis = Analysis.new
    @analysis.build_form_data
  end

  def create
    @analysis = Analysis.new
    @analysis.build_form_data(form_data_params)

    if @analysis.save
      redirect_to @analysis, notice: 'Analysis started! We\'ll search across 150+ data sources and validate with our critic agent.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @analysis = Analysis.find(params[:id])

    respond_to do |format|
      format.html {
        # Use wider layout for completed analyses
        render layout: @analysis.completed? ? 'analysis_results' : 'application'
      }
      format.json { render json: analysis_status_json }
    end
  end

  private

  def form_data_params
    params.require(:analysis).require(:form_data_attributes).permit(
      # Company Snapshot
      :company_name, :company_url, :industry_business_model, :industry_other,
      :annual_revenue_band, :company_size, :technical_maturity,

      # Role to Hire
      :role_title, :department_function, :department_other, :seniority_level,
      :employment_type, :location_type, :working_hours_timezone, :onsite_location,
      :must_have_skills, :monthly_budget_ceiling, :compensation_other,
      :contract_length, :deadline_to_fill,

      # Pain Point & Goals
      :pain_point_other, :desired_outcome, :current_kpi_baseline, :target_improvement,

      # Tools & Process Context
      :existing_tools_stack, :existing_tools_custom, :manual_tasks_friction,
      :tried_automating, :data_formats_other,

      # Constraints & Compliance
      :regulatory_other, :data_residency_needs, :security_other,

      # Arrays (when you re-enable serialization)
      preferred_compensation_model: [],
      primary_pain_point: [],
      key_integrations: [],
      regulatory_flags: [],
      security_requirements: [],
      main_data_formats: []
    )
  end

  def analysis_status_json
    {
      id: @analysis.id,
      status: @analysis.status,
      progress: @analysis.progress_percentage,
      agents_completed: @analysis.agents_completed,
      agents_failed: @analysis.agents_failed,
      results: @analysis.completed? ? @analysis.final_results : nil,
      error_message: @analysis.error_message,
      data_quality: @analysis.data_quality_summary,
      # Enhanced fields for reasoning validation
      reasoning_validated: @analysis.reasoning_validated,
      critic_review: @analysis.critic_review,
      reasoning_chains: @analysis.completed? ? @analysis.reasoning_chains : nil,

      # New: Form data context for AI
      form_context: @analysis.form_data&.to_context_hash
    }
  end
end
