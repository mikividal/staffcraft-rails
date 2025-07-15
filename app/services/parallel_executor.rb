class ParallelExecutor
  # Strategies for execution
  EXECUTION_STRATEGIES = {
    parallel: :execute_parallel,
    sequential: :execute_sequential,
    batch: :execute_batch
  }.freeze

  def self.execute_agents(agents, form_data)
    total_tokens = agents.sum { |a| a[:tokens] }
    strategy = determine_execution_strategy(total_tokens, agents.size)

    Rails.logger.info "Executing #{agents.size} agents using #{strategy} strategy (estimated #{total_tokens} total tokens)"
    Rails.logger.info "Rate limit status: #{ClaudeClient.rate_limit_stats}"

    # Use the strategy mapping to call the correct method
    method_name = EXECUTION_STRATEGIES[strategy]
    send(method_name, agents, form_data)
  end

  private

  def self.determine_execution_strategy(total_tokens, agent_count)
  # Force sequential for now due to severe rate limit issues
    Rails.logger.info "Forcing sequential execution due to immediate rate limit failures"
    return :sequential
  end
    # rate_limit_capacity = ClaudeClient::TOKEN_LIMIT_PER_MINUTE * ClaudeClient::BUFFER_PERCENTAGE
    # current_usage = ClaudeClient.rate_limit_stats[:current_usage]
    # available_capacity = rate_limit_capacity - current_usage

    # Rails.logger.debug "Strategy decision: #{total_tokens} tokens needed, #{available_capacity} available"

    # # Si no hay suficiente capacidad disponible, ir secuencial
    # if total_tokens > available_capacity
    #   Rails.logger.info "Not enough rate limit capacity, using sequential execution"
    #   return :sequential
    # end

    # # Si hay muchos agentes pero capacidad limitada, usar batches
    # if agent_count > 3 && total_tokens > (rate_limit_capacity * 0.6)
    #   Rails.logger.info "High token usage with multiple agents, using batch execution"
    #   return :batch
    # end

    # # Si hay pocos agentes y capacidad suficiente, paralelo
    # Rails.logger.info "Sufficient capacity available, using parallel execution"
    # :parallel
  # end

  def self.execute_sequential(agents, form_data)
    Rails.logger.info "Executing #{agents.size} agents sequentially"
    results = {}

    agents.each_with_index do |agent_config, index|
      Rails.logger.info "Executing agent #{index + 1}/#{agents.size}: #{agent_config[:name]}"

      start_time = Time.current

      begin
        result = execute_single_agent(agent_config, form_data)
        results[agent_config[:name]] = result

        execution_time = Time.current - start_time
        Rails.logger.info "Agent #{agent_config[:name]} completed in #{execution_time.round(2)}s, used #{result[:tokens_used]} tokens"

        # Pausa inteligente entre agentes
        if index < agents.size - 1
          pause_time = calculate_inter_agent_pause(agent_config[:tokens], execution_time)
          if pause_time > 0
            Rails.logger.info "Pausing #{pause_time}s before next agent"
            sleep(pause_time)
          end
        end

      rescue => e
        Rails.logger.error "Agent #{agent_config[:name]} failed: #{e.message}"
        results[agent_config[:name]] = create_error_result(agent_config, e.message, Time.current - start_time)
      end
    end

    results
  end

  def self.execute_batch(agents, form_data)
    batch_size = calculate_optimal_batch_size(agents)
    results = {}

    Rails.logger.info "Executing #{agents.size} agents in batches of #{batch_size}"

    agents.each_slice(batch_size).with_index do |batch, batch_index|
      batch_number = batch_index + 1
      total_batches = (agents.size.to_f / batch_size).ceil

      Rails.logger.info "Processing batch #{batch_number}/#{total_batches} with #{batch.size} agents"

      batch_start_time = Time.current
      batch_results = execute_batch_parallel(batch, form_data)
      batch_execution_time = Time.current - batch_start_time

      results.merge!(batch_results)

      # Pausa entre batches si no es el último
      if batch_number < total_batches
        inter_batch_pause = calculate_inter_batch_pause(batch, batch_execution_time)
        if inter_batch_pause > 0
          Rails.logger.info "Inter-batch pause: #{inter_batch_pause}s (rate limit management)"
          sleep(inter_batch_pause)
        end
      end
    end

    results
  end

  def self.execute_parallel(agents, form_data)
    Rails.logger.info "Executing #{agents.size} agents in parallel"
    results = {}

    # Usar threads limitados para evitar overwhelming la API
    max_concurrent_threads = [agents.size, 3].min
    Rails.logger.info "Using maximum #{max_concurrent_threads} concurrent threads"

    # Dividir agentes en grupos si hay muchos
    if agents.size > max_concurrent_threads
      agents.each_slice(max_concurrent_threads).each_with_index do |agent_group, group_index|
        Rails.logger.info "Processing parallel group #{group_index + 1}"
        group_results = execute_parallel_group(agent_group, form_data)
        results.merge!(group_results)

        # Pequeña pausa entre grupos
        sleep(2) if group_index < (agents.size.to_f / max_concurrent_threads).ceil - 1
      end
    else
      results = execute_parallel_group(agents, form_data)
    end

    results
  end

  def self.execute_parallel_group(agents, form_data)
    results = {}
    threads = []

    # Crear threads para cada agente
    agents.each do |agent_config|
      thread = Thread.new do
        Thread.current[:agent_name] = agent_config[:name]
        Thread.current[:start_time] = Time.current

        begin
          execute_single_agent(agent_config, form_data)
        rescue => e
          Rails.logger.error "Thread for #{agent_config[:name]} failed: #{e.message}"
          create_error_result(agent_config, e.message, Time.current - Thread.current[:start_time])
        end
      end

      threads << { thread: thread, agent_config: agent_config }
    end

    # Recopilar resultados con timeout
    threads.each do |thread_info|
      begin
        # Timeout generoso para agentes que pueden hacer web searches
        result = Timeout::timeout(180) { thread_info[:thread].value }
        agent_name = thread_info[:agent_config][:name]
        results[agent_name] = result

        Rails.logger.info "Parallel agent #{agent_name} completed, used #{result[:tokens_used]} tokens"

      rescue Timeout::Error
        agent_name = thread_info[:agent_config][:name]
        Rails.logger.error "Agent #{agent_name} timed out after 180s"
        thread_info[:thread].kill
        results[agent_name] = create_error_result(
          thread_info[:agent_config],
          "Execution timeout after 180 seconds",
          180
        )
      rescue => e
        agent_name = thread_info[:agent_config][:name]
        Rails.logger.error "Error collecting result for #{agent_name}: #{e.message}"
        results[agent_name] = create_error_result(thread_info[:agent_config], e.message, 0)
      end
    end

    results
  end

  def self.execute_batch_parallel(batch, form_data)
    Rails.logger.info "Executing batch of #{batch.size} agents in parallel"
    execute_parallel_group(batch, form_data)
  end

  def self.execute_single_agent(agent_config, form_data)
    start_time = Time.current

    agent_class = agent_config[:class_name].constantize
    agent = agent_class.new(form_data)
    prompt = agent.build_prompt

    claude_client = ClaudeClient.new
    response = claude_client.complete_with_search(prompt, agent_config[:tokens])

    {
      output: response[:content],
      tokens_used: response[:total_tokens],
      searches: response[:searches_performed],
      data_quality: response[:data_quality],
      reasoning_chain: response[:reasoning_chain],
      validation_status: response[:validation_status],
      api_status: response[:api_status],
      execution_time: Time.current - start_time,
      agent_config: agent_config[:name]
    }
  rescue => e
    Rails.logger.error "Agent #{agent_config[:name]} failed: #{e.message}"
    Rails.logger.error e.backtrace.join("\n") if Rails.env.development?

    create_error_result(agent_config, e.message, Time.current - start_time)
  end

  def self.create_error_result(agent_config, error_message, execution_time)
    {
      output: {
        'error' => true,
        'message' => "Agent processing failed: #{error_message}",
        'fallback_data' => {}
      },
      tokens_used: 0,
      searches: [],
      data_quality: {
        confidence: 'none',
        source: 'error',
        error_details: error_message
      },
      reasoning_chain: {
        steps: ['Error occurred - no reasoning available'],
        confidence: 'none'
      },
      validation_status: 'error',
      api_status: 'failed',
      execution_time: execution_time,
      agent_config: agent_config[:name],
      error: error_message
    }
  end

  def self.calculate_optimal_batch_size(agents)
    rate_limit_capacity = ClaudeClient::TOKEN_LIMIT_PER_MINUTE * ClaudeClient::BUFFER_PERCENTAGE
    max_batch_capacity = rate_limit_capacity * 0.4 # Usar máximo 40% del límite por batch

    # Encontrar el tamaño de batch óptimo
    batch_size = 1
    current_tokens = 0

    agents.each do |agent|
      if current_tokens + agent[:tokens] <= max_batch_capacity
        current_tokens += agent[:tokens]
      else
        break
      end
      batch_size += 1
    end

    # Mínimo 2, máximo igual al número de agentes
    optimal_size = [batch_size, 2].max
    final_size = [optimal_size, agents.size].min

    Rails.logger.info "Calculated optimal batch size: #{final_size} (max capacity: #{max_batch_capacity} tokens)"
    final_size
  end

  def self.calculate_inter_agent_pause(agent_tokens, execution_time)
    # Pausa más larga para agentes que usan más tokens
    base_pause = 90
    token_factor = (agent_tokens / 1000.0).ceil

    # Pausa más corta si el agente fue rápido (probablemente no hizo web search)
    time_factor = execution_time < 10 ? 0.5 : 1.0

    pause = (base_pause + token_factor) * time_factor
    [pause, 180].min # Máximo 5 segundos
  end

  def self.calculate_inter_batch_pause(batch, batch_execution_time)
    # Calcular pausa basada en tokens totales del batch y tiempo de ejecución
    batch_tokens = batch.sum { |agent| agent[:tokens] }
    base_pause = 3

    # Factor basado en tokens
    token_factor = (batch_tokens / 2000.0).ceil

    # Factor basado en tiempo (si fue muy rápido, probablemente hit rate limits)
    time_factor = batch_execution_time < 30 ? 1.5 : 1.0

    pause = (base_pause + token_factor) * time_factor
    [pause, 15].min # Máximo 15 segundos entre batches
  end

  # Método de utilidad para monitoreo
  def self.execution_stats
    {
      rate_limit_stats: ClaudeClient.rate_limit_stats,
      timestamp: Time.current
    }
  end
end
