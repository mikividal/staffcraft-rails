class AnalysisOrchestrator
  PARALLEL_AGENTS = [
    { name: 'Market & Salary Intelligence', class_name: 'AiAgents::MarketIntelligence', tokens: 3500 },
    { name: 'Technology & Tools Performance', class_name: 'AiAgents::TechnologyPerformance', tokens: 3500 },
    { name: 'Implementation Feasibility', class_name: 'AiAgents::ImplementationFeasibility', tokens: 3000 },
    { name: 'ROI & Business Impact', class_name: 'AiAgents::RoiBusinessImpact', tokens: 3000 },
    { name: 'Risk & Compliance Analysis', class_name: 'AiAgents::RiskCompliance', tokens: 2500 }
  ].freeze

  CRITIC_AGENT = {
    name: 'Critical Analysis & Validation',
    class_name: 'AiAgents::CriticAgent',
    tokens: 4000
  }.freeze

  SYNTHESIZER = {
    name: 'Strategic Options Synthesizer',
    class_name: 'AiAgents::StrategicSynthesizer',
    tokens: 3000
  }.freeze

  def initialize(analysis)
    @analysis = analysis
    @form_data = analysis.form_data
    @total_tokens = 0
    @execution_start_time = nil
    @data_quality_summary = {
      high_confidence: [],
      medium_confidence: [],
      low_confidence: [],
      missing_data: [],
      failed_agents: []
    }
  end

  def execute
    @execution_start_time = Time.current
    Rails.logger.info "Starting analysis ##{@analysis.id}"
    Rails.logger.info "Initial rate limit status: #{ClaudeClient.rate_limit_stats}"

    @analysis.update!(status: :processing, started_at: @execution_start_time)

    # Execute parallel agents with intelligent rate limiting
    parallel_results = execute_parallel_agents

    # Execute critic agent with rate limit consideration
    @analysis.update!(status: :validating)
    critic_results = execute_critic(parallel_results)

    # Execute synthesizer with critic feedback
    final_results = execute_synthesizer(parallel_results, critic_results)

    # Compile everything
    compile_final_results(parallel_results, critic_results, final_results)

  rescue => e
    Rails.logger.error "Analysis failed: #{e.message}"
    Rails.logger.error "Final rate limit status: #{ClaudeClient.rate_limit_stats}"

    @analysis.update!(
      status: :failed,
      error_message: e.message,
      final_results: {
        error: true,
        message: "Analysis could not be completed: #{e.message}",
        partial_data: @data_quality_summary,
        rate_limit_info: ClaudeClient.rate_limit_stats
      }
    )
    raise
  end

  private

  def execute_parallel_agents
    total_estimated_tokens = PARALLEL_AGENTS.sum { |a| a[:tokens] }
    Rails.logger.info "Executing #{PARALLEL_AGENTS.count} agents (estimated #{total_estimated_tokens} tokens)"

    # Log rate limit status before parallel execution
    rate_stats = ClaudeClient.rate_limit_stats
    Rails.logger.info "Pre-execution rate limit: #{rate_stats[:current_usage]}/#{rate_stats[:limit]} tokens (#{rate_stats[:capacity_used_percentage]}%)"

    results = ParallelExecutor.execute_agents(PARALLEL_AGENTS, @form_data)

    results.each do |agent_name, result|
      process_agent_result(agent_name, result)
    end

    # Log rate limit status after parallel execution
    post_stats = ClaudeClient.rate_limit_stats
    Rails.logger.info "Post-execution rate limit: #{post_stats[:current_usage]}/#{post_stats[:limit]} tokens (#{post_stats[:capacity_used_percentage]}%)"

    results
  end

  def execute_critic(parallel_results)
    Rails.logger.info "Executing critic agent to validate reasoning"

    # Check rate limit before critic execution
    if should_delay_critic_execution?
      delay_time = calculate_critic_delay
      Rails.logger.info "Delaying critic execution by #{delay_time}s for rate limit management"
      sleep(delay_time)
    end

    begin
      agent = CRITIC_AGENT[:class_name].constantize.new(@form_data, parallel_results)
      prompt = agent.build_prompt

      claude_client = ClaudeClient.new
      response = claude_client.complete_with_search(prompt, CRITIC_AGENT[:tokens])

      critic_result = process_critic_response(response)
      @total_tokens += response[:total_tokens]

      critic_result

    rescue => e
      Rails.logger.error "Critic agent failed: #{e.message}"

      # Create fallback critic result
      fallback_critic_result = create_fallback_critic_result(e.message)
      store_critic_result(fallback_critic_result, 0)

      fallback_critic_result
    end
  end

  def process_critic_response(response)
    critic_result = {
      output: response[:content],
      tokens_used: response[:total_tokens],
      reasoning_chain: response[:reasoning_chain],
      validation_status: response[:validation_status]
    }

    # Store critic review
    @analysis.update!(
      critic_review: response[:content],
      reasoning_validated: response[:content]['overallValidation'] == 'PASS'
    )

    store_critic_result(response[:content], response[:total_tokens])

    critic_result
  end

  def store_critic_result(content, tokens_used)
    @analysis.agent_results.create!(
      agent_name: CRITIC_AGENT[:name],
      agent_output: content,
      tokens_used: tokens_used,
      reasoning_chain: content.is_a?(Hash) ? content['reasoningChain'] : {},
      data_sources: {
        validation_performed: true,
        issues_found: content.is_a?(Hash) ? (content['reasoningIssues'] || []) : []
      },
      status: :completed
    )
  end

  def create_fallback_critic_result(error_message)
    {
      output: {
        'status' => 'validation_failed',
        'message' => 'Critic validation could not be completed due to rate limits',
        'error' => error_message,
        'overallValidation' => 'UNKNOWN',
        'reasoningIssues' => ['Validation could not be performed due to API limits']
      },
      tokens_used: 0,
      reasoning_chain: { error: 'Validation failed', confidence: 'none' },
      validation_status: 'failed'
    }
  end

  def execute_synthesizer(parallel_results, critic_results)
    Rails.logger.info "Executing synthesizer with all results and critic feedback"

    # Check rate limit before synthesizer execution
    if should_delay_synthesizer_execution?
      delay_time = calculate_synthesizer_delay
      Rails.logger.info "Delaying synthesizer execution by #{delay_time}s for rate limit management"
      sleep(delay_time)
    end

    begin
      enhanced_results = parallel_results.merge(
        'Data Quality Summary' => @data_quality_summary,
        'Critic Validation' => critic_results[:output]
      )

      agent = SYNTHESIZER[:class_name].constantize.new(@form_data, enhanced_results)
      prompt = agent.build_prompt

      claude_client = ClaudeClient.new
      response = claude_client.complete_with_search(prompt, SYNTHESIZER[:tokens])

      @analysis.agent_results.create!(
        agent_name: SYNTHESIZER[:name],
        agent_output: response[:content],
        tokens_used: response[:total_tokens],
        reasoning_chain: response[:reasoning_chain],
        data_sources: {
          searches: response[:searches_performed],
          data_quality: response[:data_quality]
        },
        status: :completed
      )

      @total_tokens += response[:total_tokens]

      response[:content]

    rescue => e
      Rails.logger.error "Synthesizer failed: #{e.message}"

      # Create fallback synthesis
      create_fallback_synthesis(parallel_results, e.message)
    end
  end

  def create_fallback_synthesis(parallel_results, error_message)
    {
      'status' => 'synthesis_failed',
      'message' => 'Final synthesis could not be completed due to rate limits',
      'error' => error_message,
      'partial_insights' => extract_key_insights_from_parallel_results(parallel_results),
      'data_quality_warning' => 'Complete synthesis unavailable due to API rate limits'
    }
  end

  def extract_key_insights_from_parallel_results(results)
    insights = {}

    results.each do |agent_name, result|
      next if result[:error] || !result[:output]

      insights[agent_name.downcase.gsub(/[&\s]+/, '_')] = {
        summary: result[:output].is_a?(Hash) ? result[:output]['summary'] || 'No summary available' : 'Data available',
        confidence: result[:data_quality]&.dig(:overall_confidence) || 'unknown',
        tokens_used: result[:tokens_used] || 0
      }
    end

    insights
  end

  def should_delay_critic_execution?
    rate_stats = ClaudeClient.rate_limit_stats
    rate_stats[:capacity_used_percentage] > 70 # Si se ha usado más del 70% del límite
  end

  def should_delay_synthesizer_execution?
    rate_stats = ClaudeClient.rate_limit_stats
    rate_stats[:capacity_used_percentage] > 80 # Si se ha usado más del 80% del límite
  end

  def calculate_critic_delay
    rate_stats = ClaudeClient.rate_limit_stats

    if rate_stats[:capacity_used_percentage] > 90
      30 # Esperar 30 segundos si está muy alto
    elsif rate_stats[:capacity_used_percentage] > 80
      15 # Esperar 15 segundos si está alto
    else
      5  # Esperar 5 segundos por defecto
    end
  end

  def calculate_synthesizer_delay
    calculate_critic_delay + 5 # Un poco más de tiempo para el synthesizer
  end

  def process_agent_result(agent_name, result)
    # Track data quality
    if result[:api_status] == 'failed'
      @data_quality_summary[:failed_agents] << agent_name
    elsif result[:data_quality]
      case result[:data_quality][:confidence] || result[:data_quality][:overall_confidence]
      when 'high'
        @data_quality_summary[:high_confidence] << agent_name
      when 'medium'
        @data_quality_summary[:medium_confidence] << agent_name
      else
        @data_quality_summary[:low_confidence] << agent_name
      end

      if result[:data_quality][:missing_data]&.any?
        @data_quality_summary[:missing_data] << {
          agent: agent_name,
          fields: result[:data_quality][:missing_data]
        }
      end
    end

    @analysis.agent_results.create!(
      agent_name: agent_name,
      agent_output: result[:output] || {},
      tokens_used: result[:tokens_used] || 0,
      reasoning_chain: result[:reasoning_chain],
      reasoning_confidence: result[:reasoning_chain]&.dig(:confidence) || 'unvalidated',
      data_sources: {
        searches: result[:searches] || [],
        data_quality: result[:data_quality],
        validation_status: result[:validation_status]
      },
      status: result[:error] ? :failed : :completed,
      error_message: result[:error],
      execution_time_ms: (result[:execution_time] * 1000).to_i
    )

    @total_tokens += result[:tokens_used] || 0
  end

  def compile_final_results(parallel_results, critic_results, synthesis)
    execution_time = Time.current - @execution_start_time
    final_rate_stats = ClaudeClient.rate_limit_stats

    final_results = {
      synthesis: synthesis,
      rankings: compile_rankings(parallel_results),
      reasoning_chains: compile_reasoning_chains,
      critic_validation: critic_results[:output],
      data_transparency: {
        quality_summary: @data_quality_summary,
        sources_used: compile_sources(parallel_results),
        confidence_levels: compile_confidence_levels(parallel_results),
        caveats: generate_caveats,
        reasoning_validated: @analysis.reasoning_validated
      },
      metadata: {
        total_tokens: @total_tokens,
        total_cost: @total_tokens * 0.00003,
        processing_time: execution_time,
        agents_count: 7,
        successful_agents: 7 - @data_quality_summary[:failed_agents].count,
        parallel_execution: true,
        critic_validation_performed: !critic_results[:output]&.dig('status')&.include?('failed'),
        rate_limit_info: {
          final_usage: final_rate_stats[:current_usage],
          peak_usage_percentage: final_rate_stats[:capacity_used_percentage],
          total_api_calls: 5 + (@data_quality_summary[:failed_agents].count > 0 ? 0 : 2) # Parallel + potentially critic + synthesizer
        }
      }
    }

    @analysis.update!(
      status: :completed,
      total_tokens: @total_tokens,
      total_cost: @total_tokens * 0.00003,
      final_results: final_results,
      completed_at: Time.current
    )

    Rails.logger.info "Analysis ##{@analysis.id} completed in #{execution_time.round(2)}s using #{@total_tokens} tokens"
    Rails.logger.info "Final rate limit status: #{final_rate_stats}"
  end

  # Los demás métodos permanecen iguales
  def compile_reasoning_chains
    chains = {}

    @analysis.agent_results.each do |result|
      next unless result.reasoning_chain

      chains[result.agent_name] = {
        steps: result.reasoning_chain['steps'] || [],
        confidence: result.reasoning_chain['confidence'] || 'unvalidated',
        key_assumptions: result.reasoning_chain['key_assumptions'] || []
      }
    end

    chains
  end

  def compile_rankings(results)
    rankings = {}

    results.each do |agent_name, result|
      next if result[:error]

      category = agent_name.downcase.gsub(/[&\s]+/, '_').gsub(/_intelligence|_analysis/, '')
      rankings[category] = result[:output]
    end

    rankings
  end

  def compile_sources(results)
    sources = {
      web_searches: [],
      platforms: [],
      academic: [],
      claude_knowledge: []
    }

    results.each do |_, result|
      next unless result[:data_quality]

      if result[:searches]&.any?
        sources[:web_searches].concat(result[:searches])
      end

      if result[:data_quality][:sources]
        result[:data_quality][:sources].each do |source|
          case source
          when 'reddit', 'review_platforms', 'product_hunt'
            sources[:platforms] << source
          when 'academic'
            sources[:academic] << source
          end
        end
      end

      if result[:data_quality][:source] == 'claude_knowledge'
        sources[:claude_knowledge] << result[:agent_config]
      end
    end

    sources.transform_values(&:uniq)
  end

  def compile_confidence_levels(results)
    confidence_map = {}

    results.each do |agent_name, result|
      next unless result[:data_quality]&.dig(:confidence_levels)

      confidence_map[agent_name] = result[:data_quality][:confidence_levels]
    end

    confidence_map
  end

  def generate_caveats
    caveats = []

    if @data_quality_summary[:failed_agents].any?
      caveats << "Some data sources were unavailable: #{@data_quality_summary[:failed_agents].join(', ')}"
    end

    if @data_quality_summary[:low_confidence].any?
      caveats << "Limited data available for: #{@data_quality_summary[:low_confidence].join(', ')}"
    end

    if @data_quality_summary[:missing_data].any?
      caveats << "Some specific metrics could not be found and are estimates"
    end

    unless @analysis.reasoning_validated
      caveats << "Some reasoning chains could not be fully validated"
    end

    caveats << "Recommendations include both verified data and Claude's analysis" if @data_quality_summary[:medium_confidence].any?

    # Agregar caveats relacionados con rate limiting si es relevante
    rate_stats = ClaudeClient.rate_limit_stats
    if rate_stats[:capacity_used_percentage] > 90
      caveats << "Analysis performed under API rate limit constraints - some features may be simplified"
    end

    caveats
  end
end
