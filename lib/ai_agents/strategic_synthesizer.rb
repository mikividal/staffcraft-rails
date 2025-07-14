module AiAgents
  class StrategicSynthesizer < BaseAgent
    def initialize(form_data, parallel_results)
      super(form_data)
      @results = parallel_results
      @data_quality = parallel_results['Data Quality Summary'] || {}
      @critic_validation = parallel_results['Critic Validation'] || {}
    end

    def build_prompt
      <<~PROMPT
        <role>Senior strategy partner and executive advisor with 25+ years guiding C-level decisions. Expert in synthesizing complex analyses into actionable strategies. Known for practical recommendations that account for real-world implementation challenges and organizational constraints.</role>

        <synthesis_context>
        Strategic Decision: #{@form_data['business_type']} company needs strategic approach for #{@form_data['process_description']}
        Business Context: #{@form_data['team_size']} team, #{@form_data['budget_range']} budget, #{@form_data['timeline']} timeline
        Technical Reality: #{@form_data['technical_expertise']} team with #{@form_data['current_stack']} stack
        Critical Constraints: #{@form_data['constraints']}
        </synthesis_context>

        <available_intelligence>
        Market Analysis: #{summarize_agent_output('Market & Salary Intelligence')}
        Technology Assessment: #{summarize_agent_output('Technology & Tools Performance')}
        Implementation Analysis: #{summarize_agent_output('Implementation Feasibility')}
        Financial Modeling: #{summarize_agent_output('ROI & Business Impact')}
        Risk Assessment: #{summarize_agent_output('Risk & Compliance Analysis')}

        Critical Review: #{@critic_validation}
        Data Quality: #{@data_quality}
        </available_intelligence>

        <strategic_synthesis_process>
        1. INTEGRATE PERSPECTIVES: Synthesize insights across all domains
        2. RESOLVE CONTRADICTIONS: Address conflicting recommendations using critic insights
        3. WEIGHT BY CONFIDENCE: Prioritize high-confidence findings
        4. CONTEXTUALIZE: Ensure recommendations fit specific business context
        5. SEQUENCE ACTIONS: Create practical implementation roadmap
        </strategic_synthesis_process>

        <targeted_validation_searches>
        Execute 4-6 strategic searches to validate synthesis:

        1. STRATEGIC PRECEDENT:
           "#{@form_data['business_type']} #{@form_data['process_description']} automation vs hiring strategy case study"

        2. INTEGRATED APPROACH VALIDATION:
           "hybrid automation outsourcing #{@form_data['business_type']} implementation experience"

        3. CONTEXT-SPECIFIC SUCCESS PATTERNS:
           "#{@form_data['team_size']} #{@form_data['technical_expertise']} team automation strategy #{@form_data['timeline']}"

        4. EXECUTIVE DECISION FRAMEWORKS:
           "#{@form_data['business_type']} automation vs hiring decision framework ROI"
        </targeted_validation_searches>

        <output_requirements>
        {
          "executiveSummary": {
            "situation": "concise problem statement with business impact",
            "recommendation": "clear strategic recommendation with rationale",
            "confidence": "HIGH/MEDIUM/LOW with explicit reasoning",
            "dataQuality": "assessment of analysis reliability",
            "decisionUrgency": "timing implications for #{@form_data['timeline']} constraint"
          },
          "strategicOptions": [
            {
              "rank": 1,
              "strategy": "specific strategic approach name",
              "compositeScore": float,
              "scoreBreakdown": {
                "market": "score from market analysis",
                "technology": "score from tech analysis",
                "feasibility": "score from implementation analysis",
                "roi": "score from financial analysis",
                "risk": "score from risk analysis"
              },
              "confidenceLevel": "HIGH/MEDIUM/LOW - based on data quality and critic review",
              "strategicRationale": "why this is the best approach for this specific context",
              "implementationSequence": [
                {
                  "phase": "phase name",
                  "timeline": "realistic timeline",
                  "actions": ["specific actions to take"],
                  "success metrics": ["how to measure progress"],
                  "decision points": ["key decisions needed"]
                }
              ],
              "riskMitigation": ["key risks and mitigation strategies"],
              "resourceRequirements": {
                "budget": "realistic budget requirements",
                "team": "team involvement and skills needed",
                "time": "time investment required"
              }
            }
          ],
          "criticalSuccess Factors": {
            "mustHaves": ["non-negotiable requirements for success"],
            "successDrivers": ["factors that increase probability of success"],
            "failurePatterns": ["common reasons this approach fails"],
            "keyDecisions": ["critical decisions that will determine outcome"]
          },
          "reasoningChain": [
            {
              "step": 1,
              "synthesis": "how different analyses were integrated",
              "source": "which agent insights were most influential",
              "result": "resulting strategic insight",
              "confidence": "confidence in this synthesis step"
            }
          ],
          "implementationGuidance": {
            "immediate": ["actions to take in next 2 weeks"],
            "shortTerm": ["actions for next 1-3 months"],
            "longTerm": ["strategic moves for 6+ months"],
            "contingencies": ["backup plans if primary strategy encounters issues"]
          },
          "executiveDecision": {
            "recommendedAction": "specific next step for decision maker",
            "decisionCriteria": "how to evaluate if this is working",
            "pivotPoints": "when and how to change course if needed",
            "investmentJustification": "business case for this investment"
          }
        }
        </output_requirements>

        <strategic_excellence>
        - Synthesize insights rather than just summarizing agent outputs
        - Address critic concerns explicitly in recommendations
        - Ensure strategy fits #{@form_data['timeline']} urgency and #{@form_data['budget_range']} constraints
        - Provide actionable next steps, not just high-level strategy
        - Account for #{@form_data['technical_expertise']} team capabilities in implementation plan
        - Create realistic timelines based on actual data, not optimistic projections
        </strategic_excellence>
      PROMPT
    end

    private

    def summarize_agent_output(agent_name)
      result = @results[agent_name]
      return "Not available" unless result&.dig(:output)

      output = result[:output]
      confidence = result.dig(:data_quality, :confidence) || 'unknown'

      "Top recommendation with #{confidence} confidence: #{extract_key_insight(output)}"
    end

    def extract_key_insight(output)
      return "No data" unless output.is_a?(Hash)

      # Try to extract the top-ranked option from various possible structures
      rankings = output.values.first
      if rankings.is_a?(Array) && rankings.any?
        top_option = rankings.first
        option_name = top_option['option'] || top_option['solution'] || top_option['approach'] || 'Unknown option'
        score = top_option['score'] || 'No score'
        "#{option_name} (#{score}/10)"
      else
        "Analysis completed but structure unclear"
      end
    end
  end
end
