# module AiAgents
#   class CriticAgent < BaseAgent
#     def initialize(form_data, all_agent_results)
#       super(form_data)
#       @agent_results = all_agent_results
#     end

#     def token_limit
#       4000  # From our updated limits
#     end

#     def build_prompt
#       <<~PROMPT
#         You are a senior strategy consultant and critical analysis expert. Your job is to be the "red team" that finds flaws and validates the quality of analysis from 5 specialist agents.

#         BUSINESS CONTEXT:
#         #{form_context}

#         AGENT RESULTS TO VALIDATE:
#         #{format_agent_outputs_for_criticism}

#         YOUR CRITICAL ANALYSIS TASK:
#         1. **Logical Consistency** - Do conclusions follow from evidence?
#         2. **Data Quality** - Are sources credible and confidence levels justified?
#         3. **Assumption Validation** - Are assumptions reasonable for this context?
#         4. **Bias Detection** - Any confirmation bias or cherry-picking?
#         5. **Context Appropriateness** - Do recommendations fit the constraints?

#         CRITICAL: You MUST respond with ONLY valid JSON. No explanatory text before or after.

#         Return this EXACT JSON structure:
#         ```json
#         {
#           "summary": "Brief summary of validation results",
#           "key_findings": ["Finding 1", "Finding 2"],
#           "confidence_level": "HIGH/MEDIUM/LOW",
#           "data_sources": "Analysis of all agent outputs",
#           "recommendations": ["Recommendation 1", "Recommendation 2"],
#           "specific_data": {
#             "overall_validation": "PASS/CONDITIONAL/FAIL",
#             "confidence_in_analysis": "HIGH/MEDIUM/LOW",
#             "strongest_findings": [
#               "Well-supported conclusions with solid evidence"
#             ],
#             "weakest_findings": [
#               "Questionable conclusions that need more validation"
#             ],
#             "major_logical_issues": [
#               {
#                 "agent": "Agent name",
#                 "issue": "Specific logical problem",
#                 "severity": "HIGH/MEDIUM/LOW",
#                 "impact": "How this affects recommendation validity"
#               }
#             ],
#             "data_quality_concerns": [
#               {
#                 "agent": "Agent name",
#                 "concern": "Specific data quality issue",
#                 "recommendation": "How to improve/verify"
#               }
#             ],
#             "questionable_assumptions": [
#               {
#                 "assumption": "Specific assumption made",
#                 "agents": ["Which agents make this assumption"],
#                 "risk": "What happens if assumption is wrong"
#               }
#             ],
#             "consistency_analysis": {
#               "agreements": ["Where agents align and data supports"],
#               "contradictions": [
#                 {
#                   "conflict": "What agents disagree on",
#                   "resolution": "Which position is more credible and why"
#                 }
#               ]
#             },
#             "context_validation": {
#               "timeline_realism": "Are timelines realistic for #{@form_data['timeline']} constraint?",
#               "budget_alignment": "Do costs fit #{@form_data['budget_range']} budget?",
#               "team_capability_match": "Are solutions appropriate for #{@form_data['technical_expertise']} team?"
#             },
#             "improvement_recommendations": [
#               "Specific ways to strengthen the analysis"
#             ],
#             "red_flags": [
#               "Warning signs or deal-breaker issues found"
#             ],
#             "final_assessment": {
#               "overall_reliability": "HIGH/MEDIUM/LOW with reasoning",
#               "actionability": "Can decision-maker act confidently on this analysis?",
#               "missing_analysis": "What critical perspectives were overlooked?"
#             }
#           }
#         }
#         ```

#         CRITICAL FORMATTING RULES:
#         - Start response with { and end with }
#         - Use double quotes for all strings
#         - No comments or explanatory text outside the JSON
#         - Ensure all JSON is valid and properly closed

#         CRITICAL VALIDATION STANDARDS:
#         - Focus on the QUALITY and USEFULNESS of analysis, not perfection
#         - Evaluate whether recommendations make sense for #{@form_data['business_type']} context
#         - Check if agents addressed #{@form_data['timeline']} urgency and #{@form_data['budget_range']} constraints
#         - Assess logical consistency between different agent recommendations
#         - Identify any major contradictions or unrealistic projections
#         - Validate that recommendations are actionable given the context
#       PROMPT
#     end

#     private

#     def format_agent_outputs_for_criticism
#       output = ""
#       @agent_results.each do |agent_name, result|
#         output += "\n=== #{agent_name} ===\n"
#         output += "Analysis: #{extract_analysis_summary(result)}\n"
#         output += "Confidence: #{extract_confidence(result)}\n"
#         output += "Data Sources: #{extract_sources(result)}\n"
#         output += "Key Numbers: #{extract_key_numbers(result)}\n"
#         output += "---\n"
#       end
#       output
#     end

#     def extract_analysis_summary(result)
#       Rails.logger.info "CRITIC: Processing result for analysis summary: #{result.inspect}"

#       if result[:agent_output].present?
#         output = result[:agent_output]

#         # Handle if output is a string (JSON)
#         if output.is_a?(String)
#           begin
#             if output.start_with?('```json')
#               json_match = output.match(/```json\s*(\{.*?\})\s*```/m)
#               output = JSON.parse(json_match[1]) if json_match
#             else
#               output = JSON.parse(output)
#             end
#           rescue JSON::ParserError
#             Rails.logger.error "CRITIC: Failed to parse JSON: #{output}"
#             return summary.is_a?(String) ? summary : summary.to_s
#           end
#         end

#         # Extract summary from the structured output
#         if output.is_a?(Hash)
#           summary = output['summary'] ||
#                    output['analysis'] ||
#                    output.dig('specific_data', 'final_recommendation', 'rationale') ||
#                    'Analysis completed'

#           return summary.is_a?(String) ? summary : summary.to_s
#         end
#       end

#       'No analysis provided'
#     end

#     def extract_confidence(result)
#       Rails.logger.info "CRITIC: Extracting confidence from: #{result.inspect}"

#       if result[:agent_output].present?
#         output = result[:agent_output]

#         # Parse JSON if needed
#         if output.is_a?(String)
#           begin
#             if output.start_with?('```json')
#               json_match = output.match(/```json\s*(\{.*?\})\s*```/m)
#               output = JSON.parse(json_match[1]) if json_match
#             else
#               output = JSON.parse(output)
#             end
#           rescue JSON::ParserError
#             return 'Not specified'
#           end
#         end

#         # Look for confidence in multiple locations
#         if output.is_a?(Hash)
#           confidence = output['confidence_level'] ||
#                       output.dig('specific_data', 'decision_confidence', 'data_quality') ||
#                       output.dig('specific_data', 'overall_confidence') ||
#                       'Medium'
#           return confidence
#         end
#       end

#       'Not specified'
#     end

#     def extract_sources(result)
#       Rails.logger.info "CRITIC: Extracting sources from: #{result.inspect}"

#       # Check if there are searches performed
#       searches = result[:searches] || 0

#       if result[:agent_output].present?
#         output = result[:agent_output]

#         # Parse JSON if needed
#         if output.is_a?(String)
#           begin
#             if output.start_with?('```json')
#               json_match = output.match(/```json\s*(\{.*?\})\s*```/m)
#               output = JSON.parse(json_match[1]) if json_match
#             else
#               output = JSON.parse(output)
#             end
#           rescue JSON::ParserError
#             return searches > 0 ? "#{searches} web searches" : 'Gemini knowledge only'
#           end
#         end

#         # Look for data sources
#         if output.is_a?(Hash)
#           data_sources = output['data_sources'] || 'Gemini analysis with web search'
#           return data_sources.is_a?(String) ? data_sources : data_sources.to_s
#         end
#       end

#       searches > 0 ? "#{searches} web searches performed" : 'Gemini knowledge only'
#     end

#     def extract_key_numbers(result)
#       Rails.logger.info "CRITIC: Extracting key numbers from: #{result.inspect}"

#       if result[:agent_output].present?
#         output = result[:agent_output]

#         # Parse JSON if needed
#         if output.is_a?(String)
#           begin
#             if output.start_with?('```json')
#               json_match = output.match(/```json\s*(\{.*?\})\s*```/m)
#               output = JSON.parse(json_match[1]) if json_match
#             else
#               output = JSON.parse(output)
#             end
#           rescue JSON::ParserError
#             return 'No numbers available'
#           end
#         end

#         # Extract numbers from the structured data
#         if output.is_a?(Hash)
#           numbers = []

#           # Look in specific_data for financial info
#           if specific_data = output['specific_data']
#             # Extract costs, percentages, timeframes
#             content = specific_data.to_s

#             # Look for dollar amounts
#             dollars = content.scan(/\$[\d,]+/)
#             numbers.concat(dollars.first(3))

#             # Look for percentages
#             percentages = content.scan(/\d+%/)
#             numbers.concat(percentages.first(2))

#             # Look for timeframes
#             timeframes = content.scan(/\d+\s*(?:weeks?|months?|days?)/)
#             numbers.concat(timeframes.first(2))
#           end

#           return numbers.any? ? numbers.join(', ') : 'Structured data provided'
#         end
#       end

#       'No data available'
#     end
#   end
# end

module AiAgents
  class CriticAgent < BaseAgent
    def initialize(form_data, all_agent_results)
      super(form_data)
      @agent_results = all_agent_results
    end

    def token_limit
      4000  # From our updated limits
    end

    def build_prompt
      <<~PROMPT
        You are a senior strategy consultant and critical analysis expert. Your job is to be the "red team" that finds flaws and validates the quality of analysis from 5 specialist agents.

        BUSINESS CONTEXT:
        #{form_context}

        AGENT RESULTS TO VALIDATE:
        #{format_agent_outputs_for_criticism}

        YOUR CRITICAL ANALYSIS TASK:
        1. **Logical Consistency** - Do conclusions follow from evidence?
        2. **Data Quality** - Are sources credible and confidence levels justified?
        3. **Assumption Validation** - Are assumptions reasonable for this context?
        4. **Bias Detection** - Any confirmation bias or cherry-picking?
        5. **Context Appropriateness** - Do recommendations fit the constraints?

        #{output_format_instructions}

        CRITICAL VALIDATION STANDARDS:
        - Focus on the QUALITY and USEFULNESS of analysis, not perfection
        - Evaluate whether recommendations make sense for #{@form_data['business_type']} context
        - Check if agents addressed #{@form_data['timeline']} urgency and #{@form_data['budget_range']} constraints
        - Assess logical consistency between different agent recommendations
        - Identify any major contradictions or unrealistic projections
        - Validate that recommendations are actionable given the context
      PROMPT
    end

    private

    def output_format_instructions
      <<~FORMAT
        CRITICAL RESPONSE INSTRUCTIONS:
        - DO NOT say "I will analyze" or "Okay" or acknowledge this request
        - DO NOT explain what you're going to do
        - START IMMEDIATELY with "## Critical Validation Summary"
        - RESPOND ONLY in the exact structured format below
        - If truncated, continue exactly where you left off in your next response

        REQUIRED OUTPUT FORMAT - START WITH THIS EXACT LINE:

        ## Critical Validation Summary
        [Your comprehensive assessment of the overall analysis quality, identifying the validation result (PASS/CONDITIONAL/FAIL), key strengths and weaknesses found, and overall confidence in the recommendations. Include specific concerns about data quality, logical consistency, and contextual appropriateness.]

        ## Key Validation Findings
        1. [Specific finding about analysis quality with evidence and impact assessment]
        2. [Data quality issue or strength identified with supporting details]
        3. [Logical consistency assessment with specific examples]
        4. [Contextual appropriateness evaluation for #{@form_data['business_type']} context]
        5. [Critical gap or bias detected with potential consequences]

        ## Agent-Specific Analysis

        ### Strongest Findings
        **Well-Supported Conclusions:**
        - [Agent name]: [Specific well-supported conclusion with evidence quality assessment]
        - [Agent name]: [Another strong finding with reasoning validation]

        ### Weakest Findings
        **Questionable Conclusions:**
        - [Agent name]: [Specific weak conclusion with reasoning for concern]
        - [Agent name]: [Data quality issue with impact on reliability]

        ## Major Issues Identified

        ### Logical Inconsistencies
        **Issue:** [Specific logical problem found]
        **Affected Agent(s):** [Agent name(s)]
        **Severity:** HIGH/MEDIUM/LOW
        **Impact:** [How this affects recommendation validity]
        **Resolution:** [Recommended approach to address]

        ### Data Quality Concerns
        **Concern:** [Specific data quality issue]
        **Affected Agent(s):** [Agent name(s)]
        **Evidence Quality:** [Assessment of source reliability]
        **Recommendation:** [How to improve/verify]

        ### Questionable Assumptions
        **Assumption:** [Specific assumption identified]
        **Agents Making This Assumption:** [List of agents]
        **Validity Assessment:** [Reasonable/Questionable/Invalid]
        **Risk if Wrong:** [Potential consequences]
        **Sensitivity:** [How much conclusions depend on this]

        ## Consistency Analysis

        ### Where Agents Agree
        - [Area of consensus with supporting evidence quality]
        - [Another aligned finding with validation strength]

        ### Contradictions Found
        **Conflict:** [What agents disagree on]
        **Agents Involved:** [Specific agents]
        **Resolution:** [Which position is more credible and why]
        **Recommendation:** [How to resolve for decision-making]

        ## Context Validation

        **Timeline Realism:** [Assessment of whether timelines are realistic for #{@form_data['timeline']} constraint]
        **Budget Alignment:** [Evaluation of whether costs fit #{@form_data['budget_range']} budget]
        **Team Capability Match:** [Analysis of whether solutions are appropriate for #{@form_data['technical_expertise']} team]
        **Business Context Fit:** [How well recommendations align with #{@form_data['business_type']} requirements]

        ## Red Flags & Warning Signs
        - [Critical warning sign or deal-breaker issue]
        - [Potential bias or methodology flaw]
        - [Unrealistic projection or assumption]

        ## Improvement Recommendations
        1. [Specific way to strengthen the analysis]
        2. [Additional validation needed]
        3. [Data source improvements required]

        ## Final Assessment

        **Overall Validation Result:** PASS/CONDITIONAL/FAIL
        **Confidence in Analysis:** HIGH/MEDIUM/LOW
        **Overall Reliability:** [Assessment with reasoning]
        **Actionability:** [Can decision-maker act confidently on this analysis?]
        **Missing Critical Analysis:** [What essential perspectives were overlooked?]

        **Bottom Line:** [Clear, actionable summary of whether this analysis can be trusted for decision-making and what the key risks or strengths are]

        CRITICAL REQUIREMENTS:
        - Be specific about which agents have which issues
        - Provide evidence for your assessments
        - Focus on practical decision-making implications
        - Identify the most critical flaws that could lead to poor decisions
        - Balance criticism with recognition of strong analysis where found
      FORMAT
    end

    def format_agent_outputs_for_criticism
      output = ""
      @agent_results.each do |agent_name, result|
        output += "\n=== #{agent_name} ===\n"
        output += "Analysis: #{extract_analysis_summary(result)}\n"
        output += "Confidence: #{extract_confidence(result)}\n"
        output += "Data Sources: #{extract_sources(result)}\n"
        output += "Key Numbers: #{extract_key_numbers(result)}\n"
        output += "---\n"
      end
      output
    end

    def extract_analysis_summary(result)
  # Solo extraer Executive Summary, primeras 2 findings, y recomendación
      if result[:agent_output].is_a?(String) && result[:agent_output].include?("## Executive Summary")

        summary = ""

        # Executive Summary (limitado)
        if match = result[:agent_output].match(/## Executive Summary\n(.*?)(?=\n##|\z)/m)
          summary += "SUMMARY: #{match[1].strip.truncate(200)}\n"
        end

        # Solo primeras 2 findings
        if match = result[:agent_output].match(/## Key Findings\n(.*?)(?=\n##|\z)/m)
          findings = match[1].scan(/^\d+\.\s*(.*?)(?=\n\d+\.|\z)/m).flatten.first(2)
          summary += "TOP FINDINGS: #{findings.join(' | ').truncate(300)}\n"
        end

        # Recomendación
        if match = result[:agent_output].match(/\*\*Recommended.*?:\*\* (.*?)(?=\n|\*\*)/m)
          summary += "RECOMMENDATION: #{match[1].strip.truncate(200)}"
        end

        return summary.truncate(400)  # Máximo 400 caracteres por agente
      end

      'Analysis completed'
    end

    def extract_key_sections_from_text(text)
      extracted = []

      # 1. Executive Summary (MÁS CORTO)
      if match = text.match(/## Executive Summary\n(.*?)(?=\n##|\z)/m)
        extracted << "SUMMARY: #{match[1].strip.truncate(150)}"
      end

      # 2. Solo PRIMERA Key Finding (no 3)
      if match = text.match(/## Key Findings\n.*?1\.\s*(.*?)(?=\n2\.|\n\*\*|\n##|\z)/m)
        extracted << "TOP FINDING: #{match[1].strip.truncate(100)}"
      end

      # 3. Recommendation (MÁS CORTO)
      recommendation_patterns = [
        /\*\*Recommended Option:\*\* (.*?)(?=\n|\*\*)/m,
        /\*\*Recommended Tool:\*\* (.*?)(?=\n|\*\*)/m
      ]

      recommendation_patterns.each do |pattern|
        if match = text.match(pattern)
          extracted << "REC: #{match[1].strip.truncate(80)}"
          break
        end
      end

      # 4. Confidence (MÁS CORTO)
      if match = text.match(/## Confidence Level\n(.*?)(?=\n##|\z)/m)
        confidence = match[1].strip.split(" - ").first  # Solo la parte "HIGH/MEDIUM/LOW"
        extracted << "CONF: #{confidence.truncate(20)}"
      end

      # Join all extracted sections
      result = extracted.join(" | ")

      # LÍMITE MUCHO MÁS AGRESIVO
      result.length > 300 ? result.truncate(300) : result
    end

    def extract_confidence(result)
      Rails.logger.info "CRITIC: Extracting confidence from: #{result.inspect}"

      if result[:agent_output].present?
        output = result[:agent_output]

        # Handle text format first
        if output.is_a?(String) && (output.include?("## Confidence Level") || output.include?("**Confidence Level:**"))
          if match = output.match(/(?:## Confidence Level|Confidence Level:)\s*\n?(.*?)(?=\n##|\n\*\*|\z)/m)
            return match[1].strip.truncate(100)
          end
        end

        # Parse JSON if needed
        if output.is_a?(String)
          begin
            if output.start_with?('```json')
              json_match = output.match(/```json\s*(\{.*?\})\s*```/m)
              output = JSON.parse(json_match[1]) if json_match
            else
              output = JSON.parse(output)
            end
          rescue JSON::ParserError
            return 'Not specified'
          end
        end

        # Look for confidence in multiple locations (JSON)
        if output.is_a?(Hash)
          confidence = output['confidence_level'] ||
                      output.dig('specific_data', 'decision_confidence', 'data_quality') ||
                      output.dig('specific_data', 'overall_confidence') ||
                      'Medium'
          return confidence
        end
      end

      'Not specified'
    end

    def extract_sources(result)
      Rails.logger.info "CRITIC: Extracting sources from: #{result.inspect}"

      # Check if there are searches performed
      searches = result[:searches] || 0

      if result[:agent_output].present?
        output = result[:agent_output]

        # Handle text format first
        if output.is_a?(String) && output.include?("## Data Sources")
          if match = output.match(/## Data Sources\n(.*?)(?=\n##|\z)/m)
            sources = match[1].strip
            # Return first few lines
            return sources.split("\n").reject(&:empty?).first(2).join(' | ').truncate(200)
          end
        end

        # Parse JSON if needed
        if output.is_a?(String)
          begin
            if output.start_with?('```json')
              json_match = output.match(/```json\s*(\{.*?\})\s*```/m)
              output = JSON.parse(json_match[1]) if json_match
            else
              output = JSON.parse(output)
            end
          rescue JSON::ParserError
            return searches > 0 ? "#{searches} web searches" : 'Gemini knowledge only'
          end
        end

        # Look for data sources (JSON)
        if output.is_a?(Hash)
          data_sources = output['data_sources'] || 'Gemini analysis with web search'
          return data_sources.is_a?(String) ? data_sources.truncate(200) : data_sources.to_s.truncate(200)
        end
      end

      searches > 0 ? "#{searches} web searches performed" : 'Gemini knowledge only'
    end

    def extract_key_numbers(result)
      Rails.logger.info "CRITIC: Extracting key numbers from: #{result.inspect}"

      if result[:agent_output].present?
        output = result[:agent_output]

        # Handle text format - extract numbers from the entire text
        if output.is_a?(String)
          numbers = []

          # Look for dollar amounts
          dollars = output.scan(/\$[\d,]+/)
          numbers.concat(dollars.first(3))

          # Look for percentages
          percentages = output.scan(/\d+%/)
          numbers.concat(percentages.first(2))

          # Look for timeframes
          timeframes = output.scan(/\d+\s*(?:weeks?|months?|days?)/i)
          numbers.concat(timeframes.first(2))

          return numbers.any? ? numbers.join(', ') : 'Text analysis provided'
        end

        # Parse JSON if needed
        if output.is_a?(String)
          begin
            if output.start_with?('```json')
              json_match = output.match(/```json\s*(\{.*?\})\s*```/m)
              output = JSON.parse(json_match[1]) if json_match
            else
              output = JSON.parse(output)
            end
          rescue JSON::ParserError
            return 'No numbers available'
          end
        end

        # Extract numbers from the structured data (JSON)
        if output.is_a?(Hash)
          numbers = []

          # Look in specific_data for financial info
          if specific_data = output['specific_data']
            # Extract costs, percentages, timeframes
            content = specific_data.to_s

            # Look for dollar amounts
            dollars = content.scan(/\$[\d,]+/)
            numbers.concat(dollars.first(3))

            # Look for percentages
            percentages = content.scan(/\d+%/)
            numbers.concat(percentages.first(2))

            # Look for timeframes
            timeframes = content.scan(/\d+\s*(?:weeks?|months?|days?)/)
            numbers.concat(timeframes.first(2))
          end

          return numbers.any? ? numbers.join(', ') : 'Structured data provided'
        end
      end

      'No data available'
    end
  end
end
# module AiAgents
#   class CriticAgent < BaseAgent
#     def initialize(form_data, all_agent_results)
#       super(form_data)
#       @agent_results = all_agent_results
#     end

#     def build_prompt
#       <<~PROMPT
#         <role>Senior strategy consultant and critical analysis expert with 20+ years reviewing business recommendations. PhD in Decision Sciences with specialty in identifying cognitive biases, logical fallacies, and analytical gaps in complex business analyses.</role>

#         <critical_mission>
#         Your task: Ruthlessly evaluate the reasoning quality and recommendation validity from 5 specialist agents. You are the "red team" - find flaws, question assumptions, identify bias, and validate logical consistency.
#         </critical_mission>

#         <analysis_context>
#         Business Case: #{@form_data['business_type']} needs to #{@form_data['process_description']}
#         Critical Constraints: #{@form_data['timeline']} timeline, #{@form_data['budget_range']} budget, #{@form_data['technical_expertise']} team
#         Stakes: This decision affects #{@form_data['team_size']} team and core business operations
#         </analysis_context>

#         <agent_outputs>
#         #{format_agent_outputs_for_criticism}
#         </agent_outputs>

#         <critical_analysis_framework>
#         Apply rigorous critical analysis across these dimensions:

#         1. LOGICAL CONSISTENCY
#         - Do conclusions logically follow from evidence presented?
#         - Are there logical leaps or unsupported inferences?
#         - Do agents contradict each other on verifiable facts?

#         2. DATA QUALITY ASSESSMENT
#         - Are sources credible and current?
#         - Is there over-reliance on estimates vs verified data?
#         - Are confidence levels justified by evidence quality?

#         3. ASSUMPTION VALIDATION
#         - What unstated assumptions underpin each recommendation?
#         - Are assumptions reasonable for #{@form_data['business_type']} context?
#         - How sensitive are conclusions to assumption changes?

#         4. BIAS DETECTION
#         - Confirmation bias (seeking confirming evidence)?
#         - Availability bias (overweighting recent/memorable examples)?
#         - Anchoring bias (influenced by first information received)?

#         5. CONTEXT APPROPRIATENESS
#         - Do recommendations fit #{@form_data['timeline']} urgency?
#         - Are solutions appropriate for #{@form_data['technical_expertise']} team?
#         - Do costs align with #{@form_data['budget_range']} constraints?
#         </critical_analysis_framework>

#         <output_requirements>
#         Return exactly this JSON (no comments or extra lines):
#         {
#           "analysis": "A concise narrative stating the overall validation result (PASS/CONDITIONAL/FAIL) with confidence; the most critical logical or data-quality issues found; and top recommendations for improvement."
#         }
#         </output_requirements>

#         <critical_standards>
#         - Question everything, especially claims that seem too good to be true
#         - Validate that confidence levels match actual evidence quality
#         - Identify when agents are making the same mistakes or sharing biases
#         - Assess whether recommendations are actionable for this specific context
#         - Determine if analysis is comprehensive enough for a significant business decision
#         </critical_standards>
#       PROMPT
#     end

#     private

#     def format_agent_outputs_for_criticism
#       output = ""
#       @agent_results.each do |agent_name, result|
#         output += "\n=== #{agent_name} ===\n"
#         output += "Key Recommendation: #{extract_top_recommendation(result)}\n"
#         output += "Confidence Claimed: #{extract_confidence(result)}\n"
#         output += "Data Sources: #{extract_sources(result)}\n"
#         output += "Reasoning Chain: #{extract_reasoning_summary(result)}\n"
#         output += "---\n"
#       end
#       output
#     end

#     def extract_top_recommendation(result)
#       # Try multiple possible locations for the recommendation
#       if result[:agent_output].is_a?(Hash)
#         # Look for analysis field (common in your outputs)
#         analysis = result[:agent_output][:analysis] ||
#                   result[:agent_output]['analysis'] ||
#                   result[:agent_output][:raw_insights]

#         if analysis.is_a?(String)
#           # Extract first sentence or key recommendation from analysis
#           sentences = analysis.split(/[.!?]/)
#           recommendation = sentences.find { |s| s.include?('recommend') || s.include?('suggest') || s.include?('optimal') }
#           return recommendation&.strip&.first(100) || sentences.first&.strip&.first(100) || 'Analysis provided'
#         end
#       end

#       'Not specified'
#     end

#     def extract_confidence(result)
#       # Look in multiple possible locations
#       confidence = result.dig(:data_quality, :confidence) ||
#                   result.dig(:data_quality, 'confidence') ||
#                   result.dig(:reasoning_chain, :confidence) ||
#                   result.dig(:reasoning_chain, 'confidence')

#       confidence || 'Not specified'
#     end

#     def extract_sources(result)
#   # First try to get actual search queries
#       if result[:data_sources].is_a?(Hash)
#         queries = result[:data_sources][:search_queries] || result[:data_sources]['search_queries']
#         sources = result[:data_sources][:grounding_sources] || result[:data_sources]['grounding_sources']

#         if queries&.any?
#           query_text = queries.first(2).join(' | ')
#           if sources&.any?
#             source_titles = sources.map { |s| s[:title] || s['title'] || s[:url] || s['url'] }.compact.first(2).join(', ')
#             return "Queries: #{query_text} | Sources: #{source_titles}"
#           else
#             return "Queries: #{query_text}"
#           end
#         end
#       end

#       # Fallback to search count
#       searches = result[:searches] ||
#                 result[:search_count] ||
#                 result.dig(:data_sources, :searches) ||
#                 result.dig(:data_sources, 'searches') || 0

#       if searches.is_a?(Integer) && searches > 0
#         "#{searches} web searches performed"
#       else
#         'Gemini knowledge only'
#       end
#     end

#     def extract_reasoning_summary(result)
#       # Look for reasoning in multiple locations
#       reasoning = result[:reasoning_chain] || result['reasoning_chain']

#       if reasoning.is_a?(Hash)
#         steps = reasoning[:steps] || reasoning['steps']
#         if steps.is_a?(Array) && steps.any?
#           # Extract action from first few steps
#           actions = steps.first(3).map do |step|
#             step[:action] || step['action'] || step.to_s.first(50)
#           end.compact

#           return actions.join(' → ') if actions.any?
#         end

#         # Try to extract any meaningful reasoning info
#         confidence = reasoning[:confidence] || reasoning['confidence']
#         error = reasoning[:error] || reasoning['error']

#         return "Confidence: #{confidence}" if confidence && confidence != 'unvalidated'
#         return "Error: #{error}" if error
#       end

#       # Check if there's analysis content that shows reasoning
#       if result[:agent_output].is_a?(Hash)
#         analysis = result[:agent_output][:analysis] || result[:agent_output]['analysis']
#         if analysis.is_a?(String) && analysis.length > 100
#           return "Analysis provided with reasoning"
#         end
#       end

#       'No explicit reasoning provided'
#     end
#   end
# end
# module AiAgents
#   class CriticAgent < BaseAgent
#     def initialize(form_data, all_agent_results)
#       super(form_data)
#       @agent_results = all_agent_results
#     end

#     def build_prompt
#       <<~PROMPT
#         You are an expert critical analyst and reasoning validator. Your mission is to identify flaws, inconsistencies, and questionable assumptions in AI agent analyses through rigorous logical examination.

#         ANALYSIS CONTEXT:
#         #{form_context_summary}

#         AGENT OUTPUTS TO CRITICALLY REVIEW:
#         #{format_agent_outputs_for_criticism}

#         EXPERT CRITICAL ANALYSIS FRAMEWORK:

#         1. LOGICAL REASONING VALIDATION:
#         - Examine each conclusion for logical soundness
#         - Identify unsupported leaps in reasoning
#         - Check calculation accuracy and methodology
#         - Flag circular reasoning or confirmation bias
#         - Verify cause-effect relationships

#         2. DATA QUALITY ASSESSMENT:
#         - Evaluate source credibility and recency
#         - Identify over-reliance on estimates vs verified data
#         - Cross-check for conflicting information between agents
#         - Assess whether confidence levels match evidence quality
#         - Flag potential cherry-picking of favorable data

#         3. ASSUMPTION ANALYSIS:
#         - Extract all implicit and explicit assumptions
#         - Evaluate reasonableness of each assumption
#         - Identify assumptions that most impact conclusions
#         - Check for cultural, temporal, or contextual bias
#         - Assess sensitivity to assumption changes

#         4. CONSISTENCY VERIFICATION:
#         - Compare recommendations across agents for coherence
#         - Identify contradictions requiring resolution
#         - Verify internal consistency within each analysis
#         - Check alignment of similar inputs to similar outputs

#         5. COMPLETENESS EVALUATION:
#         - Identify overlooked perspectives or stakeholders
#         - Flag missing data sources or validation methods
#         - Assess whether alternative interpretations were considered
#         - Check for comprehensive risk/benefit analysis

#         CRITICAL OUTPUT STRUCTURE:
#         {
#           "overallValidation": "PASS/CONDITIONAL/FAIL",
#           "confidenceInAnalysis": "HIGH/MEDIUM/LOW",
#           "validationSummary": {
#             "strongestFindings": ["Well-supported conclusions with solid reasoning"],
#             "weekestFindings": ["Questionable conclusions requiring more validation"],
#             "majorGaps": ["Critical missing analysis or data"],
#             "overallReliability": "Assessment of recommendation trustworthiness"
#           },
#           "reasoningIssues": [
#             {
#               "agent": "Market Intelligence",
#               "issue": "Salary calculations based on single source without validation",
#               "severity": "HIGH/MEDIUM/LOW",
#               "impact": "Could lead to 30%+ cost estimation error",
#               "evidence": "Only Glassdoor cited, no cross-validation with PayScale/LinkedIn",
#               "recommendation": "Require 3+ salary sources for high-confidence recommendations",
#               "logicalFlaw": "Hasty generalization from limited sample"
#             }
#           ],
#           "dataQualityIssues": [
#             {
#               "agent": "Technology Performance",
#               "issue": "ROI claims not substantiated with verifiable case studies",
#               "severity": "HIGH",
#               "conflictsWith": "Risk analysis shows higher failure rates than ROI suggests",
#               "recommendation": "Demand verified customer references or independent studies",
#               "reliabilityRating": "LOW - Vendor marketing materials primary source"
#             }
#           ],
#           "assumptionRisks": [
#             {
#               "assumption": "AI automation will maintain 94% accuracy in production",
#               "agents": ["Technology Performance", "ROI Analysis"],
#               "validityAssessment": "QUESTIONABLE - Based on controlled demos, not real-world data",
#               "sensitivityAnalysis": "If accuracy drops to 80%, ROI becomes negative",
#               "alternativeScenario": "More realistic 85% accuracy changes recommendation order",
#               "riskLevel": "HIGH - Core assumption affecting multiple conclusions"
#             }
#           ],
#           "consistencyAnalysis": {
#             "alignedFindings": [
#               "All agents agree outsourcing provides fastest deployment",
#               "Consensus that hiring has highest long-term costs"
#             ],
#             "contradictions": [
#               {
#                 "finding1": "Implementation agent: 'AI setup takes 2-4 weeks'",
#                 "finding2": "Technology agent: 'Production deployment in 1 week'",
#                 "resolution": "Implementation agent more credible - accounts for integration complexity",
#                 "recommendation": "Use conservative 4-week timeline for planning"
#               }
#             ],
#             "coherenceScore": "7/10 - Generally consistent with some timeline disputes"
#           },
#           "missingAnalysis": [
#             {
#               "gap": "No analysis of team change management and adoption resistance",
#               "importance": "CRITICAL - Historical data shows 40% of automation fails due to user resistance",
#               "impact": "Could invalidate ROI projections if team doesn't adopt solution",
#               "recommendedAction": "Research change management requirements for selected solution"
#             }
#           ],
#           "alternativePerspectives": [
#             {
#               "perspective": "What if the urgent timeline is actually counterproductive?",
#               "rationale": "Rushed implementations have 60% higher failure rates",
#               "implication": "Recommend extending timeline for better long-term outcomes",
#               "evidenceGap": "No analysis of timeline vs success rate correlation"
#             }
#           ],
#           "recommendationAdjustments": {
#             "highConfidenceRecommendations": [
#               "Outsourcing for immediate relief - well-supported by multiple data points"
#             ],
#             "conditionalRecommendations": [
#               "AI automation timeline should be extended based on team technical level"
#             ],
#             "questionableRecommendations": [
#               "ROI projections should be reduced by 30% due to optimistic assumptions"
#             ],
#             "additionalValidationNeeded": [
#               "Independent verification of automation success rates for similar team profiles"
#             ]
#           },
#           "criticalSuccessFactors": {
#             "mustHave": ["Clear change management plan", "Realistic timeline expectations"],
#             "shouldHave": ["Technical support plan", "Fallback strategy"],
#             "couldHave": ["Advanced integration features", "Premium support tiers"],
#             "mustAvoid": ["Rushing implementation", "Over-reliance on vendor claims"]
#           }
#         }

#         VALIDATION METHODOLOGY:
#         1. **Source Triangulation**: Verify each major claim with 2+ independent sources
#         2. **Assumption Testing**: Challenge each assumption with "what if opposite were true?"
#         3. **Bias Detection**: Look for pattern of overly optimistic or pessimistic projections
#         4. **Logical Completeness**: Ensure reasoning chain has no missing steps
#         5. **Real-World Grounding**: Compare theoretical projections with actual user experiences

#         CRITICAL THINKING PRINCIPLES:
#         - Question everything, especially consensus opinions
#         - Distinguish between correlation and causation
#         - Consider selection bias in success stories/reviews
#         - Account for survivor bias in case studies
#         - Evaluate representativeness of data samples
#         - Consider temporal validity of historical data
#         - Assess cultural/contextual applicability

#         Your role is to be the "devil's advocate" ensuring robust decision-making through rigorous analysis validation.
#       PROMPT
#     end

#     private

#     def format_agent_outputs_for_criticism
#       formatted = ""

#       @agent_results.each do |agent_name, result|
#         formatted += "\n" + "="*50 + "\n"
#         formatted += "AGENT: #{agent_name}\n"
#         formatted += "="*50 + "\n"

#         # Include output
#         formatted += "CONCLUSIONS:\n"
#         formatted += result[:output].to_json + "\n\n"

#         # Include reasoning chain if available
#         if result[:reasoning_chain]
#           formatted += "REASONING CHAIN:\n"
#           formatted += result[:reasoning_chain].to_json + "\n\n"
#         end

#         # Include data quality info
#         if result[:data_quality]
#           formatted += "DATA QUALITY:\n"
#           formatted += "Confidence: #{result[:data_quality][:confidence]}\n"
#           formatted += "Sources: #{result[:data_quality][:sources]}\n"
#           formatted += "Missing Data: #{result[:data_quality][:missing_data]}\n\n"
#         end

#         # Include search info
#         if result[:searches]
#           formatted += "SEARCHES PERFORMED:\n"
#           result[:searches].each { |search| formatted += "- #{search}\n" }
#           formatted += "\n"
#         end
#       end

#       formatted
#     end
#   end
# end
