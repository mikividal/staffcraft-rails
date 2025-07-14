module AiAgents
  class CriticAgent < BaseAgent
    def initialize(form_data, all_agent_results)
      super(form_data)
      @agent_results = all_agent_results
    end

    def build_prompt
      <<~PROMPT
        <role>Senior strategy consultant and critical analysis expert with 20+ years reviewing business recommendations. PhD in Decision Sciences with specialty in identifying cognitive biases, logical fallacies, and analytical gaps in complex business analyses.</role>

        <critical_mission>
        Your task: Ruthlessly evaluate the reasoning quality and recommendation validity from 5 specialist agents. You are the "red team" - find flaws, question assumptions, identify bias, and validate logical consistency.
        </critical_mission>

        <analysis_context>
        Business Case: #{@form_data['business_type']} needs to #{@form_data['process_description']}
        Critical Constraints: #{@form_data['timeline']} timeline, #{@form_data['budget_range']} budget, #{@form_data['technical_expertise']} team
        Stakes: This decision affects #{@form_data['team_size']} team and core business operations
        </analysis_context>

        <agent_outputs>
        #{format_agent_outputs_for_criticism}
        </agent_outputs>

        <critical_analysis_framework>
        Apply rigorous critical analysis across these dimensions:

        1. LOGICAL CONSISTENCY
        - Do conclusions logically follow from evidence presented?
        - Are there logical leaps or unsupported inferences?
        - Do agents contradict each other on verifiable facts?

        2. DATA QUALITY ASSESSMENT
        - Are sources credible and current?
        - Is there over-reliance on estimates vs verified data?
        - Are confidence levels justified by evidence quality?

        3. ASSUMPTION VALIDATION
        - What unstated assumptions underpin each recommendation?
        - Are assumptions reasonable for #{@form_data['business_type']} context?
        - How sensitive are conclusions to assumption changes?

        4. BIAS DETECTION
        - Confirmation bias (seeking confirming evidence)?
        - Availability bias (overweighting recent/memorable examples)?
        - Anchoring bias (influenced by first information received)?

        5. CONTEXT APPROPRIATENESS
        - Do recommendations fit #{@form_data['timeline']} urgency?
        - Are solutions appropriate for #{@form_data['technical_expertise']} team?
        - Do costs align with #{@form_data['budget_range']} constraints?
        </critical_analysis_framework>

        <output_requirements>
        {
          "overallValidation": "PASS/CONDITIONAL/FAIL",
          "confidenceInAnalysis": "HIGH/MEDIUM/LOW",
          "criticalFindings": {
            "logicalFlaws": [
              {
                "agent": "agent_name",
                "flaw": "specific logical issue",
                "evidence": "what data doesn't support the conclusion",
                "severity": "HIGH/MEDIUM/LOW",
                "impact": "how this affects recommendation validity"
              }
            ],
            "dataQualityIssues": [
              {
                "agent": "agent_name",
                "issue": "specific data problem",
                "sourceQuality": "assessment of source credibility",
                "recommendation": "how to improve/verify"
              }
            ],
            "questionableAssumptions": [
              {
                "assumption": "specific assumption made",
                "agents": ["which agents make this assumption"],
                "validity": "assessment of assumption reasonableness",
                "alternativeScenario": "what happens if assumption is wrong"
              }
            ],
            "biasDetection": [
              {
                "bias": "type of bias detected",
                "manifestation": "how it appears in analysis",
                "correction": "adjusted perspective"
              }
            ]
          },
          "consistencyAnalysis": {
            "agreements": ["where agents align and data supports"],
            "contradictions": [
              {
                "issue": "what agents disagree on",
                "agent1Position": "first position",
                "agent2Position": "contradicting position",
                "resolution": "which is more credible and why"
              }
            ],
            "confidenceAlignment": "do confidence levels match evidence quality?"
          },
          "contextValidation": {
            "timelineRealism": "are timelines realistic for #{@form_data['timeline']} constraint?",
            "budgetAlignment": "do costs fit #{@form_data['budget_range']} budget?",
            "teamCapabilityMatch": "are solutions appropriate for #{@form_data['technical_expertise']} team?",
            "businessFit": "do recommendations suit #{@form_data['business_type']} context?"
          },
          "improvementRecommendations": {
            "dataGaps": ["what additional data would strengthen analysis"],
            "analysisDepth": ["where deeper investigation is needed"],
            "alternativePerspectives": ["what viewpoints were missed"],
            "riskFactors": ["underexplored risks that matter"]
          },
          "finalAssessment": {
            "strongestRecommendations": ["most reliable conclusions"],
            "weakestRecommendations": ["most questionable conclusions"],
            "overallReliability": "HIGH/MEDIUM/LOW with reasoning",
            "actionability": "can decision-maker act on this analysis confidently?"
          }
        }
        </output_requirements>

        <critical_standards>
        - Question everything, especially claims that seem too good to be true
        - Validate that confidence levels match actual evidence quality
        - Identify when agents are making the same mistakes or sharing biases
        - Assess whether recommendations are actionable for this specific context
        - Determine if analysis is comprehensive enough for a significant business decision
        </critical_standards>
      PROMPT
    end

    private

    def format_agent_outputs_for_criticism
      output = ""
      @agent_results.each do |agent_name, result|
        output += "\n=== #{agent_name} ===\n"
        output += "Key Recommendation: #{extract_top_recommendation(result)}\n"
        output += "Confidence Claimed: #{extract_confidence(result)}\n"
        output += "Data Sources: #{extract_sources(result)}\n"
        output += "Reasoning Chain: #{extract_reasoning_summary(result)}\n"
        output += "---\n"
      end
      output
    end

    def extract_top_recommendation(result)
      output = result[:output] || {}
      if output.is_a?(Hash)
        rankings = output.values.first
        rankings.is_a?(Array) ? rankings.first&.dig('option') || 'Not specified' : 'Not specified'
      else
        'Not specified'
      end
    end

    def extract_confidence(result)
      result[:data_quality]&.dig('confidence') || 'Not specified'
    end

    def extract_sources(result)
      searches = result[:searches] || []
      searches.any? ? searches.join(', ') : 'Claude knowledge only'
    end

    def extract_reasoning_summary(result)
      reasoning = result[:reasoning_chain]
      if reasoning&.dig('steps')&.any?
        steps = reasoning['steps'][0..2] # First 3 steps only
        steps.map { |s| s['action'] }.join(' → ')
      else
        'No explicit reasoning provided'
      end
    end
  end
end
