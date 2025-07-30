
module AiAgents
  class BaseAgent
    def initialize(form_data, previous_results = {})
      @form_data = form_data.respond_to?(:to_context_hash) ? form_data.to_context_hash : form_data
      @previous_results = previous_results
    end

    def build_prompt
      raise NotImplementedError, "Subclasses must implement build_prompt"
    end

    def execute
      start_time = Time.current

      begin
        prompt = build_prompt
        client = GeminiClient.new
        response = client.complete_with_search(prompt, max_tokens: token_limit)

        {
          output: parse_json_response(response[:content]),
          tokens_used: response.dig(:usage, :total_tokens) || 0,
          execution_time: Time.current - start_time,
          status: response[:status]
        }
      rescue => e
        Rails.logger.error "Agent #{self.class.name} failed: #{e.message}"

        {
          output: { error: e.message },
          tokens_used: 0,
          execution_time: Time.current - start_time,
          status: 'error'
        }
      end
    end

    # private

    #  def safe_token_count(response)
    #   return 0 unless response.is_a?(Hash)

    #   usage = response[:usage] || response["usage"]
    #   return 0 unless usage

    #   usage[:total_tokens] || usage["total_tokens"] || 0
    # rescue => e
    #   Rails.logger.warn "⚠️ Could not extract token count in #{self.class.name}: #{e.message}"
    #   0
    # end

    protected

    def token_limit
      # Override in subclasses if needed
      1500
    end


    def parse_json_response(content)
      # Log the raw response for debugging
      Rails.logger.info "AGENT #{self.class.name} RAW RESPONSE: #{content}..."

      # Clean the content first
      cleaned_content = content.strip

      # Remove any markdown formatting if present
      if cleaned_content.start_with?('```json')
        json_match = cleaned_content.match(/```json\s*(\{.*?\})\s*```/m)
        if json_match
          cleaned_content = json_match[1]
        end
      end

      # Try to parse as JSON
      begin
        parsed = JSON.parse(cleaned_content)
        Rails.logger.info "AGENT #{self.class.name} SUCCESSFULLY PARSED JSON"
        return parsed
      rescue JSON::ParserError
        # If direct parsing fails, try to extract JSON from the response
        json_match = content.match(/\{.*\}/m)
        if json_match
          begin
            parsed = JSON.parse(json_match[0])
            Rails.logger.info "AGENT #{self.class.name} EXTRACTED AND PARSED JSON"
            return parsed
          rescue JSON::ParserError
            Rails.logger.error "AGENT #{self.class.name} FAILED TO PARSE EXTRACTED JSON"
          end
        end

        Rails.logger.error "AGENT #{self.class.name} JSON PARSE ERROR. Content: #{content}"
        # Return a structured fallback
        return {
          "summary" => content.strip,
          "analysis" => content.strip,
          "confidence_level" => "LOW",
          "key_findings" => ["Analysis completed but format issue occurred"],
          "recommendations" => ["Review the analysis manually"],
          "data_sources" => "Gemini analysis"
        }
      end
    end

    def form_context
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

    def data_quality_instructions
      <<~INSTRUCTIONS
        IMPORTANT: Data Source Transparency

        For EVERY data point in your response, indicate the source:
        - If from web search: Mark as "Source: [platform name]"
        - If from Gemini's training: Mark as "Source: Gemini knowledge"
        - If missing/not found: Mark as "Data not available" or provide range with "Estimated based on similar roles"
        - If low confidence: Add "Low confidence - limited data"

        Include confidence indicators:
        - HIGH: Data from multiple recent sources or authoritative platforms
        - MEDIUM: Data from single source or older data extrapolated
        - LOW: General estimates based on pre-training knowledge
        - NONE: Data not found - clearly indicate this

        Structure your response to clearly separate:
        1. Verified data from searches
        2. Gemini's knowledge-based estimates
        3. Missing data that couldn't be found

        If searches fail or return no results, provide estimates but CLEARLY mark them as such. DO NOT HALUCINATE.
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

          Please account for these gaps in your analysis and clearly indicate any assumptions made by explicitly stating them.
        CONTEXT
      else
        ""
      end
    end

    def output_format_instructions
      <<~FORMAT
        IMPORTANT: Respond with valid JSON in this exact format:

        ```json
        {
          "summary": "This should be a comprehensive 4-6 sentence analysis that provides substantial context, explains the significance of findings, discusses implications, and sets up the key discoveries. It should give readers a thorough understanding of what was analyzed, why it matters, and what the overall conclusions indicate about the subject matter.",
          "key_findings": [
            "Specific, detailed finding 1 with concrete data points and context",
            "Specific, detailed finding 2 with measurable outcomes or clear evidence",
            "Specific, detailed finding 3 with quantitative or qualitative insights",
            "Specific, detailed finding 4 with comparative analysis or trend identification",
            "Specific, detailed finding 5 with actionable intelligence or critical insights"
          ],
          "specific_data": {
            // Agent-specific structured data with detailed metrics,
            // charts, tables, or other relevant analytical content
            // This section should contain the most granular information
          },
          "confidence_level": "HIGH/MEDIUM/LOW with justification for the confidence rating",
          "data_sources": "Complete list of specific URLs, documents, databases, or other sources used in the analysis. Only include public, human-readable URLs. Avoid redirect links from Google Vertex or internal APIs. Format each source with a title and a visible, verifiable URL",
          "recommendations": [
            "Specific, actionable recommendation 1: Do X by implementing Y strategy within Z timeframe, targeting specific metrics or outcomes",
            "Specific, actionable recommendation 2: Take concrete action A to address finding B, with measurable success criteria and implementation steps",
            "Specific, actionable recommendation 3: Implement specific solution C to optimize D, including resource requirements and expected ROI"
          ]
        }
        ```

        This JSON structure is CRITICAL for the final synthesis.
      FORMAT
    end
  end
end
