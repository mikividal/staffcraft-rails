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
