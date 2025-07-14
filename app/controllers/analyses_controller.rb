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
    params.require(:analysis).require(:form_data).permit(
      :process_description, :business_type, :role_type,
      :experience_level, :key_skills, :budget_range,
      :country, :team_size, :technical_expertise,
      :current_stack, :constraints, :timeline
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
      reasoning_chains: @analysis.completed? ? @analysis.reasoning_chains : nil
    }
  end
end
