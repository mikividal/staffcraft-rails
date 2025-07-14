# lib/ai_agents/base_agent.rb
module AiAgents
  class BaseAgent
    def initialize(form_data, previous_results = {})
      @form_data = form_data.respond_to?(:to_context_hash) ? form_data.to_context_hash : form_data
      @previous_results = previous_results
      @data_quality_context = previous_results['Data Quality Summary'] if previous_results
    end

    def execute
      start_time = Time.current

      begin
        # Build the prompt
        prompt = build_prompt

        # Call Claude API
        client = ClaudeClient.new
        response = client.call(prompt)

        # Calculate execution time
        execution_time = ((Time.current - start_time) * 1000).round

        # Process response and extract structured data
        processed_response = process_response(response)

        # Return structured result
        {
          status: 'completed',
          agent_output: processed_response[:output],
          data_sources: processed_response[:sources],
          reasoning_chain: processed_response[:reasoning],
          execution_time_ms: execution_time,
          tokens_used: response[:usage]&.dig(:total_tokens) || 0,
          data_quality: processed_response[:quality],
          validation_status: processed_response[:validation]
        }

      rescue => e
        execution_time = ((Time.current - start_time) * 1000).round
        Rails.logger.error "Agent #{self.class.name} failed: #{e.message}"

        # Return error result with fallback
        {
          status: 'failed',
          agent_output: { error: e.message, fallback: generate_fallback_response },
          data_sources: { error: "Failed to fetch data", source: "error" },
          reasoning_chain: { error: "Execution failed", steps: [] },
          execution_time_ms: execution_time,
          tokens_used: 0,
          error_message: e.message
        }
      end
    end

    def build_prompt
      raise NotImplementedError, "Subclasses must implement build_prompt"
    end

    protected

    def process_response(response)
      content = response[:content] || response.to_s

      # Try to extract JSON from the response
      json_match = content.match(/```json\s*(\{.*?\})\s*```/m)
      if json_match
        begin
          parsed_json = JSON.parse(json_match[1])
          return {
            output: parsed_json,
            sources: extract_sources(content),
            reasoning: extract_reasoning(parsed_json),
            quality: assess_data_quality(parsed_json),
            validation: "structured_json"
          }
        rescue JSON::ParserError
          # Fall through to raw processing
        end
      end

      # If no valid JSON found, return raw insights
      {
        output: { raw_insights: content },
        sources: extract_sources_from_raw(content),
        reasoning: { error: "No structured reasoning found" },
        quality: { confidence: "low", source: "claude_knowledge" },
        validation: "no_json"
      }
    end

    def extract_sources(content)
      sources = {
        searches: extract_search_queries(content),
        data_quality: { confidence: "low", source: "claude_knowledge" },
        validation_status: "no_json"
      }

      # Look for search indicators
      if content.include?("web_search") || content.include?("searching")
        sources[:data_quality][:confidence] = "medium"
        sources[:data_quality][:source] = "attempted_search"
      end

      sources
    end

    def extract_sources_from_raw(content)
      {
        searches: extract_search_queries(content),
        data_quality: { confidence: "low", source: "claude_knowledge" },
        validation_status: "no_json"
      }
    end

    def extract_search_queries(content)
      # Extract search queries from content
      queries = []

      # Look for patterns like "search for", "searching", etc.
      search_patterns = [
        /search(?:ing)?\s+for[:\s]+([^.\n]+)/i,
        /look(?:ing)?\s+up[:\s]+([^.\n]+)/i,
        /find(?:ing)?\s+data\s+on[:\s]+([^.\n]+)/i
      ]

      search_patterns.each do |pattern|
        content.scan(pattern) do |match|
          query = match[0].strip.gsub(/['""]/, '')
          queries << query if query.length > 10 && query.length < 100
        end
      end

      # Add some default searches based on the agent type
      if queries.empty?
        queries = generate_default_searches
      end

      queries.uniq.first(3) # Limit to 3 searches
    end

    def generate_default_searches
      agent_name = self.class.name.split('::').last
      role = @form_data['role_type'] || 'support specialist'
      location = @form_data['country'] || 'United Kingdom'

      case agent_name
      when 'MarketIntelligence'
        ["#{role} salary #{location} 2024 Glassdoor Indeed"]
      when 'TechnologyPerformance'
        ["#{@form_data['current_stack']} automation pricing 2024"]
      when 'ImplementationFeasibility'
        ["#{@form_data['process_description']} automation success story"]
      when 'RoiBusinessImpact'
        ["#{@form_data['business_type']} automation ROI case studies 2024"]
      when 'RiskCompliance'
        ["#{@form_data['business_type']} automation risks compliance"]
      else
        ["#{role} hiring vs automation analysis"]
      end
    end

    def extract_reasoning(parsed_json)
      reasoning = parsed_json['reasoningChain'] || parsed_json['reasoning_chain'] || []
      confidence = parsed_json['reasoningConfidence'] || parsed_json['reasoning_confidence'] || 'unvalidated'
      assumptions = parsed_json['keyAssumptions'] || parsed_json['key_assumptions'] || []

      {
        steps: reasoning,
        confidence: confidence,
        key_assumptions: assumptions
      }
    end

    def assess_data_quality(parsed_json)
      # Simple quality assessment based on structure
      has_reasoning = (parsed_json['reasoningChain'] || parsed_json['reasoning_chain']).present?
      has_sources = (parsed_json['dataSources'] || parsed_json['data_sources']).present?

      if has_reasoning && has_sources
        { confidence: "high", completeness: "full" }
      elsif has_reasoning || has_sources
        { confidence: "medium", completeness: "partial" }
      else
        { confidence: "low", completeness: "minimal" }
      end
    end

    def generate_fallback_response
      agent_name = self.class.name.split('::').last

      "I'll help gather and analyze this data with full transparency and structured reasoning. " \
      "Let me search for current information."
    end

    def knowledge_base_url
      "http://localhost:3000/knowledge_base"
    end

    def form_context_summary
      <<~CONTEXT
        Process: #{@form_data['process_description']}
        Business: #{@form_data['business_type']}
        Role: #{@form_data['role_type']} (#{@form_data['experience_level']})
        Skills: #{@form_data['key_skills']}
        Budget: #{@form_data['budget_range']}
        Location: #{@form_data['country']}
        Team Size: #{@form_data['team_size']}
        Tech Level: #{@form_data['technical_expertise']}
        Stack: #{@form_data['current_stack']}
        Constraints: #{@form_data['constraints']}
        Timeline: #{@form_data['timeline']}
      CONTEXT
    end

    def reasoning_instructions
      <<~INSTRUCTIONS
        CRITICAL: For EVERY conclusion or recommendation, you MUST provide explicit reasoning chains.

        Structure your reasoning as follows:
        "reasoningChain": [
          {
            "step": 1,
            "action": "What data or calculation was performed",
            "source": "Where the data came from",
            "result": "What was found or calculated",
            "confidence": "HIGH/MEDIUM/LOW"
          },
          {
            "step": 2,
            "action": "Next step in the reasoning",
            "source": "Source for this step",
            "result": "Result of this step",
            "confidence": "Confidence level"
          }
        ],
        "reasoningConfidence": "Overall confidence in the reasoning chain",
        "keyAssumptions": [
          "List any assumptions made in the reasoning",
          "Be explicit about what could affect the conclusions"
        ]

        Example reasoning for a cost calculation:
        {
          "step": 1,
          "action": "Retrieved base salary data for role",
          "source": "Glassdoor 2024 data for location",
          "result": "$75,000 annual base salary",
          "confidence": "HIGH"
        },
        {
          "step": 2,
          "action": "Calculated benefits cost at industry standard 30%",
          "source": "BLS employer cost data",
          "result": "$22,500 annual benefits cost",
          "confidence": "MEDIUM"
        },
        {
          "step": 3,
          "action": "Added base + benefits for total compensation",
          "source": "Calculation from steps 1 and 2",
          "result": "$97,500 total annual cost",
          "confidence": "HIGH"
        }
      INSTRUCTIONS
    end

    def data_quality_instructions
      <<~INSTRUCTIONS
        IMPORTANT: Data Source Transparency

        For EVERY data point in your response, indicate the source:
        - If from web search: Mark as "Source: [platform name]"
        - If from Claude's training: Mark as "Source: Claude knowledge"
        - If missing/not found: Mark as "Data not available" or provide range with "Estimated based on similar roles"
        - If low confidence: Add "Low confidence - limited data"

        Include confidence indicators:
        - HIGH: Data from multiple recent sources or authoritative platforms
        - MEDIUM: Data from single source or older data extrapolated
        - LOW: General estimates based on pre-training knowledge
        - NONE: Data not found - clearly indicate this

        Structure your response to clearly separate:
        1. Verified data from searches
        2. Claude's knowledge-based estimates
        3. Missing data that couldn't be found

        If searches fail or return no results, provide estimates but CLEARLY mark them as such.
      INSTRUCTIONS
    end

    def handle_previous_failures
      return "" unless @data_quality_context

      failed = @data_quality_context[:failed_agents] || []
      missing = @data_quality_context[:missing_data] || []

      if failed.any? || missing.any?
        <<~CONTEXT

          Note: Previous agents encountered data limitations:
          - Failed agents: #{failed.join(', ')}
          - Missing data points: #{missing.map { |m| m[:fields] }.flatten.join(', ')}

          Please account for these gaps in your analysis and clearly indicate any assumptions made.
        CONTEXT
      else
        ""
      end
    end
  end
end
