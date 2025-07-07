AGENTS = [
    { name: 'Comprehensive Options Strategist', class_name: 'AiAgents::OptionsStrategist', tokens: 2000 },
    { name: 'Advanced Technology Research', class_name: 'AiAgents::ToolsResearcher', tokens: 1800 },
    { name: 'Market Intelligence Expert', class_name: 'AiAgents::MarketIntelligence', tokens: 1800 },
    { name: 'Implementation Strategy Architect', class_name: 'AiAgents::ImplementationStrategy', tokens: 1500 },
    { name: 'Input Evaluation Specialist', class_name: 'AiAgents::InputEvaluator', tokens: 1500 },
    { name: 'Master Strategy Synthesizer', class_name: 'AiAgents::MasterSynthesizer', tokens: 1000 }
  ].freeze

  def initialize(analysis)
    @analysis = analysis
    @form_data = analysis.form_data
    @claude_client = ClaudeClient.new
    @total_tokens = 0
    @agent_results = {}
  end

  def execute_all_agents
    Rails.logger.info "Starting Ultra Premium Analysis for Analysis ##{@analysis.id}"

    @analysis.update!(status: :processing)

    AGENTS.each_with_index do |agent_config, index|
      execute_agent(agent_config, index + 1)
    end

    compile_final_result

  rescue => e
    Rails.logger.error "Analysis orchestration failed: #{e.message}"
    @analysis.update!(
      status: :failed,
      error_message: e.message,
      completed_at: Time.current
    )
    raise e
  end

  private

  def execute_agent(agent_config, sequence)
    Rails.logger.info "Executing agent #{sequence}/6: #{agent_config[:name]}"

    # Update current agent
    @analysis.update!(current_agent_name: agent_config[:name])

    # Create agent result record
    agent_result = @analysis.agent_results.create!(
      agent_name: agent_config[:name],
      status: :running,
      started_at: Time.current
    )

    begin
      # Get agent class and execute
      agent_class = agent_config[:class_name].constantize
      agent = agent_class.new(@form_data, @agent_results)
      prompt = agent.build_prompt

      # Execute Claude API call
      response = @claude_client.complete(
        prompt: prompt,
        max_tokens: agent_config[:tokens]
      )

      # Parse result
      parsed_result = ResultParser.new(response).parse

      # Calculate tokens
      tokens_used = estimate_tokens(prompt + response)
      @total_tokens += tokens_used

      # Update agent result
      agent_result.update!(
        status: :completed,
        agent_output: parsed_result,
        tokens_used: tokens_used,
        execution_time_ms: ((Time.current - agent_result.started_at) * 1000).round,
        completed_at: Time.current
      )

      # Store for next agents
      @agent_results[agent_config[:name]] = parsed_result

      # Broadcast progress
      broadcast_progress(sequence)

    rescue => e
      Rails.logger.error "Agent #{agent_config[:name]} failed: #{e.message}"

      agent_result.update!(
        status: :failed,
        error_message: e.message,
        completed_at: Time.current
      )

      # Continue with other agents
      @agent_results[agent_config[:name]] = { error: e.message }
    end
  end

  def broadcast_progress(completed_count)
    progress = (completed_count.to_f / 6 * 100).round(0)

    AnalysisProgressChannel.broadcast_to(
      @analysis.user,
      analysis_id: @analysis.id,
      current_agent: @analysis.current_agent_name,
      progress: progress,
      agents_completed: completed_count,
      total_agents: 6,
      total_tokens: @total_tokens
    )
  end

  def compile_final_result
    master_synthesis = @agent_results['Master Strategy Synthesizer']

    final_results = {
      executiveSynthesis: master_synthesis,
      comprehensiveOptions: @agent_results['Comprehensive Options Strategist'],
      advancedToolsResearch: @agent_results['Advanced Technology Research'],
      marketIntelligence: @agent_results['Market Intelligence Expert'],
      implementationStrategy: @agent_results['Implementation Strategy Architect'],
      inputEvaluation: @agent_results['Input Evaluation Specialist'],
      analysisMetadata: {
        analysisDate: Time.current.iso8601,
        analysisDepth: 'Ultra Premium',
        totalAgents: 6,
        totalTokens: @total_tokens,
        estimatedCost: "$#{(@total_tokens * 0.00003).round(3)}",
        processingTime: "#{@analysis.processing_time_seconds}s",
        analysisVersion: '2.0 Rails Ultra Premium',
        inputCompleteness: "#{@form_data.completeness_score}% complete"
      }
    }

    @analysis.update!(
      status: :completed,
      total_tokens: @total_tokens,
      total_cost: @total_tokens * 0.00003,
      confidence_level: extract_confidence_level(master_synthesis),
      recommended_approach: extract_recommended_approach(master_synthesis),
      final_results: final_results,
      completed_at: Time.current,
      current_agent_name: nil
    )

    # Broadcast completion
    AnalysisProgressChannel.broadcast_to(
      @analysis.user,
      status: 'completed',
      analysis_id: @analysis.id,
      redirect_url: "/api/v1/analyses/#{@analysis.id}"
    )

    final_results
  end

  def estimate_tokens(text)
    (text.length / 3.5).ceil
  end

  def extract_confidence_level(synthesis)
    synthesis&.dig('executiveInsights', 'strategicRecommendation', 'confidenceLevel') || 0
  end

  def extract_recommended_approach(synthesis)
    approach = synthesis&.dig('executiveInsights', 'strategicRecommendation', 'primaryApproach')
    return 'automation_only' unless approach

    case approach.downcase
    when /full.*hire/ then 'full_hire'
    when /automation.*only/ then 'automation_only'
    when /hybrid/ then 'hybrid_solution'
    when /outsourcing/ then 'strategic_outsourcing'
    else 'automation_only'
    end
  end
end
