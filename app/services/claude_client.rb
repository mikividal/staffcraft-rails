class ClaudeClient
  include HTTParty
  base_uri 'https://api.anthropic.com/v1'

  MAX_RETRIES = 3
  RETRY_DELAY = 2 # seconds

  # Rate limiting constants
  TOKEN_LIMIT_PER_MINUTE = 40_000
  BUFFER_PERCENTAGE = 0.75  # Usar solo 75% del límite como buffer

  # Singleton pattern para compartir el rate limiter entre instancias
  @@rate_limiter_mutex = Mutex.new
  @@token_usage_history = []

  def initialize
    @api_key = ENV['CLAUDE_API_KEY'] || Rails.application.credentials.claude_api_key
    @headers = {
      'Content-Type' => 'application/json',
      'x-api-key' => @api_key,
      'anthropic-version' => '2023-06-01'
    }

    # Asegurar que las variables de clase estén inicializadas
    @@rate_limiter_mutex ||= Mutex.new
    @@token_usage_history ||= []
  end

  def call(prompt, max_tokens = 3000)
    complete_with_search(prompt, max_tokens)
  end

  def complete_with_search(prompt, max_tokens = 3000)
    # Estimar tokens antes de hacer la llamada
    estimated_tokens = estimate_tokens(prompt) + (max_tokens * 0.3) # Input + parte del output estimado

    # Aplicar rate limiting
    apply_rate_limiting(estimated_tokens)

    retries = 0

    begin
      body = build_request_body(prompt, max_tokens)

      # Log antes de hacer el request
      Rails.logger.info "Making Claude request with ~#{estimated_tokens} tokens"

      response = self.class.post(
        '/messages',
        headers: @headers,
        body: body.to_json,
        timeout: 120
      )

      result = handle_response(response, estimated_tokens)

      # Registrar tokens reales usados después del request exitoso
      actual_tokens = result[:total_tokens] || estimated_tokens
      record_token_usage(actual_tokens)

      result

    rescue => e
      retries += 1

      # Manejo especial para rate limit errors
      if rate_limit_error?(e) && retries < MAX_RETRIES
        backoff_time = calculate_exponential_backoff(retries)
        Rails.logger.warn "Rate limit error (attempt #{retries}/#{MAX_RETRIES}), backing off #{backoff_time}s"
        sleep(backoff_time)
        retry
      elsif retries < MAX_RETRIES
        Rails.logger.warn "Claude API attempt #{retries} failed: #{e.message}. Retrying in #{RETRY_DELAY * retries}s..."
        sleep(RETRY_DELAY * retries) # Exponential backoff
        retry
      else
        Rails.logger.error "Claude API failed after #{MAX_RETRIES} attempts: #{e.message}"
        return fallback_response(prompt, e)
      end
    end
  end

  private

  def apply_rate_limiting(estimated_tokens)
    wait_time = calculate_wait_time(estimated_tokens)

    if wait_time > 0
      Rails.logger.info "Rate limiting: waiting #{wait_time.round(2)}s for #{estimated_tokens} tokens"
      sleep(wait_time)
    end

    # Double-check después de esperar
    unless can_make_request?(estimated_tokens)
      additional_wait = calculate_wait_time(estimated_tokens)
      if additional_wait > 0
        Rails.logger.warn "Additional rate limit wait needed: #{additional_wait.round(2)}s"
        sleep(additional_wait)
      end
    end
  end

  def can_make_request?(estimated_tokens)
    @@rate_limiter_mutex.synchronize do
      clean_old_usage
      current_usage = @@token_usage_history.sum(&:last)
      available_capacity = (TOKEN_LIMIT_PER_MINUTE * BUFFER_PERCENTAGE) - current_usage

      Rails.logger.debug "Rate limit check: #{current_usage}/#{TOKEN_LIMIT_PER_MINUTE} tokens used, need #{estimated_tokens}, available: #{available_capacity}"

      available_capacity >= estimated_tokens
    end
  end

  def calculate_wait_time(estimated_tokens)
    @@rate_limiter_mutex.synchronize do
      clean_old_usage
      current_usage = @@token_usage_history.sum(&:last)
      capacity_limit = TOKEN_LIMIT_PER_MINUTE * BUFFER_PERCENTAGE

      if (current_usage + estimated_tokens) > capacity_limit
        return 0 if @@token_usage_history.empty?

        # Encontrar cuánto tiempo hasta que tengamos suficiente capacidad
        sorted_usage = @@token_usage_history.sort_by(&:first)

        needed_space = (current_usage + estimated_tokens) - capacity_limit
        freed_space = 0
        target_time = nil

        sorted_usage.each do |timestamp, tokens|
          freed_space += tokens
          if freed_space >= needed_space
            target_time = timestamp + 60 # Los tokens expiran después de 1 minuto
            break
          end
        end

        if target_time
          wait_time = target_time - Time.current
          [wait_time, 0].max
        else
          # En caso extremo, esperar hasta que expire el más viejo
          oldest_timestamp = sorted_usage.first&.first
          return 0 unless oldest_timestamp

          remaining_time = (oldest_timestamp + 60) - Time.current
          [remaining_time, 0].max
        end
      else
        0
      end
    end
  end

  def record_token_usage(tokens)
    @@rate_limiter_mutex.synchronize do
      @@token_usage_history << [Time.current, tokens]
      clean_old_usage
      Rails.logger.debug "Recorded #{tokens} tokens. Total in last minute: #{@@token_usage_history.sum(&:last)}"
    end
  end

  def clean_old_usage
    cutoff_time = Time.current - 60 # 1 minuto atrás
    @@token_usage_history.reject! { |timestamp, _| timestamp < cutoff_time }
  end

  def rate_limit_error?(error)
    error.message.include?('rate_limit_error') ||
    error.message.include?('429') ||
    error.message.include?('This request would exceed the rate limit') ||
    error.is_a?(Net::HTTPTooManyRequests)
  end

  def calculate_exponential_backoff(retry_count)
    base_delay = 5 # Empezar con 5 segundos para rate limits
    max_delay = 60
    jitter = rand(0..3) # Agregar jitter para evitar thundering herd

    delay = [base_delay * (2 ** (retry_count - 1)), max_delay].min + jitter
    delay
  end

  def estimate_tokens(text)
    return 100 unless text # Valor por defecto conservador

    # Estimación conservadora: ~3.5 caracteres por token, con 25% buffer
    estimated = (text.length / 3.5 * 1.25).ceil

    # Mínimo realista para requests con context
    [estimated, 500].max
  end

  # Método para obtener estadísticas del rate limiter (útil para debugging)
  def self.rate_limit_stats
    # Asegurar que las variables de clase estén inicializadas
    @@rate_limiter_mutex ||= Mutex.new
    @@token_usage_history ||= []
    @@rate_limiter_mutex.synchronize do
      current_usage = @@token_usage_history.sum(&:last)
      capacity_used_percentage = (current_usage.to_f / TOKEN_LIMIT_PER_MINUTE * 100).round(1)

      {
        current_usage: current_usage,
        limit: TOKEN_LIMIT_PER_MINUTE,
        capacity_used_percentage: capacity_used_percentage,
        active_entries: @@token_usage_history.size,
        oldest_entry_age: @@token_usage_history.empty? ? 0 : (Time.current - @@token_usage_history.first.first).round(1)
      }
    end
  end

  def build_request_body(prompt, max_tokens)
    {
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: max_tokens,
      messages: [
        {
          role: 'user',
          content: prompt
        }
      ],
      tools: [{
        type: "web_search_20250305",
        name: "web_search",
        max_uses: 5,
        user_location: {
          type: "approximate",
          city: "London",
          region: "England",
          country: "GB",
          timezone: "Europe/London"
        }
      }]
    }
  end

  def handle_response(response, estimated_tokens = 0)
    if response.success?
      parsed = response.parsed_response

      # Extract text content
      content = parsed['content']&.find { |c| c['type'] == 'text' }&.dig('text')

      # Extract web search results
      searches = parsed['content']
        &.select { |c| c['type'] == 'tool_use' && c['name'] == 'web_search' }
        &.map { |c| c.dig('input', 'query') } || []

      # Look for tool results (search results)
      search_results = parsed['content']
        &.select { |c| c['type'] == 'tool_result' }
        &.map { |c| c['content'] } || []

      validated_content = validate_and_parse_content(content, search_results)

      {
        content: validated_content[:parsed_content],
        validation_status: validated_content[:status],
        data_quality: validated_content[:data_quality],
        reasoning_chain: validated_content[:reasoning_chain],
        searches_performed: searches,
        search_results: search_results,
        total_tokens: parsed.dig('usage', 'total_tokens') || estimated_tokens,
        api_status: 'success',
        usage: parsed['usage']
      }
    else
      Rails.logger.error "Claude API error: #{response.code} - #{response.body}"

      # Si es un error de rate limit, lanzar excepción específica
      if response.code == 429
        raise "rate_limit_error: #{response.body}"
      end

      fallback_response(nil, "API returned #{response.code}: #{response.body}")
    end
  end

  # El resto de tus métodos existentes permanecen igual...
  def validate_and_parse_content(content, search_results = [])
    return { status: 'no_content', parsed_content: {}, data_quality: {}, reasoning_chain: {} } unless content

    # Ensure content is a string
    content_str = content.is_a?(String) ? content : content.to_s

    # Try to extract JSON from the content
    json_match = content_str.match(/```json\s*(\{.*?\})\s*```/m) || content_str.match(/\{.*\}/m)

    if json_match
      begin
        json_text = json_match[1] || json_match[0]
        parsed = JSON.parse(json_text)
        data_quality = analyze_data_quality(parsed, content_str, search_results)
        reasoning_chain = extract_reasoning_chain(parsed)

        {
          status: 'success',
          parsed_content: parsed,
          data_quality: data_quality,
          reasoning_chain: reasoning_chain
        }
      rescue JSON::ParserError => e
        Rails.logger.error "Failed to parse JSON: #{e.message}"
        {
          status: 'parse_error',
          parsed_content: extract_fallback_data(content_str),
          data_quality: { confidence: 'low', source: 'extracted_text' },
          reasoning_chain: { error: 'Could not parse reasoning' }
        }
      end
    else
      {
        status: 'no_json',
        parsed_content: extract_fallback_data(content_str),
        data_quality: {
          confidence: search_results.any? ? 'medium' : 'low',
          source: search_results.any? ? 'web_search_performed' : 'claude_knowledge'
        },
        reasoning_chain: { error: 'No structured reasoning found' }
      }
    end
  end

  def extract_reasoning_chain(parsed_data)
    reasoning = parsed_data['reasoningChain'] || parsed_data['reasoning_chain'] || []
    confidence = parsed_data['reasoningConfidence'] || parsed_data['reasoning_confidence'] || 'unvalidated'
    assumptions = parsed_data['keyAssumptions'] || parsed_data['key_assumptions'] || []

    {
      steps: reasoning,
      confidence: confidence,
      key_assumptions: assumptions
    }
  end

  def analyze_data_quality(parsed_data, full_content, search_results)
    quality = {
      sources: [],
      confidence_levels: {},
      missing_data: [],
      estimations: [],
      web_search_performed: search_results.any?
    }

    # Check for source citations in content
    source_indicators = {
      'glassdoor' => ['glassdoor.com', 'glassdoor'],
      'indeed' => ['indeed.com', 'indeed'],
      'linkedin' => ['linkedin.com', 'linkedin'],
      'reddit' => ['reddit.com', 'reddit'],
      'g2' => ['g2.com', 'g2'],
      'capterra' => ['capterra.com', 'capterra'],
      'academic' => ['arxiv.org', 'scholar.google', 'ieee.org'],
      'product_hunt' => ['producthunt.com', 'product hunt'],
      'github' => ['github.com', 'github'],
      'stackoverflow' => ['stackoverflow.com', 'stack overflow']
    }

    source_indicators.each do |source, patterns|
      if patterns.any? { |pattern| full_content.downcase.include?(pattern) }
        quality[:sources] << source
      end
    end

    # Analyze search results content
    if search_results.any?
      quality[:sources] << 'web_search_results'
      search_results.each do |result|
        result_text = result.to_s.downcase
        source_indicators.each do |source, patterns|
          if patterns.any? { |pattern| result_text.include?(pattern) }
            quality[:sources] << source
          end
        end
      end
    end

    # Analyze each data field in parsed response
    parsed_data.each do |key, value|
      next if ['reasoningChain', 'reasoningConfidence', 'keyAssumptions', 'reasoning_chain', 'reasoning_confidence', 'key_assumptions'].include?(key)

      if value.nil? || (value.is_a?(String) && value.include?('N/A'))
        quality[:missing_data] << key
      elsif value.is_a?(String) && value.match?(/approximately|estimated|around|roughly/i)
        quality[:estimations] << key
        quality[:confidence_levels][key] = 'medium'
      elsif quality[:sources].any? && !quality[:sources].include?('claude_knowledge')
        quality[:confidence_levels][key] = 'high'
      else
        quality[:confidence_levels][key] = 'claude_knowledge'
      end
    end

    # Overall confidence assessment
    if search_results.any? && quality[:sources].any?
      quality[:overall_confidence] = 'high'
    elsif search_results.any? || quality[:sources].any?
      quality[:overall_confidence] = 'medium'
    else
      quality[:overall_confidence] = 'low'
    end

    quality
  end

  def extract_fallback_data(content)
    data = {}

    # Ensure content is a string
    content_str = content.is_a?(String) ? content : content.to_s

    # Extract common patterns
    if match = content_str.match(/\$(\d+(?:,\d+)?(?:\.\d+)?)/i)
      data['estimated_cost'] = match[1]
    end

    if match = content_str.match(/(\d+(?:\.\d+)?)\s*%/i)
      data['percentage_metric'] = match[1]
    end

    if match = content_str.match(/(\d+)\s*(days?|weeks?|months?)/i)
      data['timeline'] = "#{match[1]} #{match[2]}"
    end

    data['raw_insights'] = content_str.truncate(500) if content_str && content_str.length > 0
    data
  end

  def fallback_response(original_prompt, error)
    {
      content: generate_fallback_content(original_prompt),
      validation_status: 'fallback',
      data_quality: {
        confidence: 'low',
        source: 'claude_pretrained_only',
        error: error.to_s,
        note: 'Using Claude pre-trained knowledge only - web search failed'
      },
      reasoning_chain: {
        steps: ['Fallback mode - no detailed reasoning available'],
        confidence: 'low'
      },
      searches_performed: [],
      search_results: [],
      total_tokens: 0,
      api_status: 'failed_with_fallback'
    }
  end

  def generate_fallback_content(prompt)
    if prompt&.include?('market research') || prompt&.include?('salary')
      {
        'marketRankings' => [
          {
            'option' => 'full_time_hire',
            'score' => 7.0,
            'monthlyExpectedCost' => '$6,000-10,000 (estimate)',
            'dataSource' => 'Claude pre-trained knowledge',
            'confidence' => 'low',
            'note' => 'Based on general market knowledge, not current data'
          }
        ],
        'data_warning' => 'Web search unavailable - using general estimates only',
        'reasoningChain' => [
          {
            'step' => 1,
            'action' => 'Fallback estimation',
            'source' => 'Claude knowledge',
            'result' => 'General market estimates provided',
            'confidence' => 'LOW'
          }
        ]
      }
    else
      {
        'status' => 'limited_data',
        'message' => 'Unable to fetch current data - providing general guidance only',
        'confidence' => 'low',
        'raw_insights' => 'I\'ll help gather and analyze this data with full transparency and structured reasoning. Let me search for current information.',
        'reasoningChain' => [
          {
            'step' => 1,
            'action' => 'Attempted data gathering',
            'source' => 'Fallback mode',
            'result' => 'Limited to general knowledge',
            'confidence' => 'LOW'
          }
        ]
      }
    end
  end
end
