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
# module AiAgents
#   class StrategicSynthesizer < BaseAgent
#     def initialize(form_data, parallel_results)
#       super(form_data)
#       @results = parallel_results
#       @data_quality = parallel_results['Data Quality Summary'] || {}
#       @critic_validation = parallel_results['Critic Validation'] || {}
#     end

#     def build_prompt
#       synthesis_strategy = determine_synthesis_strategy
#       decision_framework = build_decision_framework

#       <<~PROMPT
#         You are a senior strategic advisor specializing in technology decisions, organizational change, and strategic synthesis. Your role is to integrate insights from 5 expert analyses plus critical validation into actionable strategic recommendations.

#         STRATEGIC CONTEXT:
#         #{form_context_summary}

#         SYNTHESIS STRATEGY:
#         #{synthesis_strategy}

#         DECISION FRAMEWORK:
#         #{decision_framework}

#         EXPERT ANALYSES TO SYNTHESIZE:
#         Market Intelligence: #{@results['Market & Salary Intelligence'][:output].to_json}
#         Technology Performance: #{@results['Technology & Tools Performance'][:output].to_json}
#         Implementation Feasibility: #{@results['Implementation Feasibility'][:output].to_json}
#         ROI & Business Impact: #{@results['ROI & Business Impact'][:output].to_json}
#         Risk & Compliance: #{@results['Risk & Compliance Analysis'][:output].to_json}

#         CRITICAL VALIDATION RESULTS:
#         #{@critic_validation.to_json}

#         DATA QUALITY LANDSCAPE:
#         High Confidence Sources: #{@data_quality[:high_confidence]&.join(', ') || 'None identified'}
#         Medium Confidence Sources: #{@data_quality[:medium_confidence]&.join(', ') || 'None identified'}
#         Low Confidence Sources: #{@data_quality[:low_confidence]&.join(', ') || 'None identified'}
#         Failed Analysis Attempts: #{@data_quality[:failed_agents]&.join(', ') || 'None'}

#         STRATEGIC SYNTHESIS SEARCHES (4-6 targeted searches):
#         1. "#{@form_data['business_type']} automation strategy best practices #{Date.current.year}"
#         2. "site:hbr.org human AI collaboration #{identify_strategic_context}"
#         3. "#{@form_data['team_size']} team technology adoption success factors"
#         4. "#{identify_strategic_context} competitive advantage automation"
#         #{generate_synthesis_specific_searches}

#         ADVANCED SYNTHESIS FRAMEWORK:

#         1. MULTI-CRITERIA DECISION ANALYSIS:
#         ```
#         Strategic_Score = Weighted_Sum(
#           Market_Viability * 0.20 +
#           Technical_Feasibility * 0.25 +
#           Implementation_Risk * 0.20 +
#           Financial_Return * 0.25 +
#           Strategic_Alignment * 0.10
#         )

#         Adjust weights based on:
#         - Timeline urgency: +10% to feasibility if ASAP
#         - Budget constraints: +15% to financial if limited
#         - Technical capability: +10% to risk if non-technical
#         ```

#         2. SCENARIO PLANNING:
#         Develop recommendations for multiple futures:
#         - Best case: Everything goes as planned
#         - Most likely: Normal implementation challenges
#         - Worst case: Significant obstacles arise

#         3. STRATEGIC OPTION VALUATION:
#         Consider real options value (ability to adapt/pivot).

#         COMPREHENSIVE OUTPUT STRUCTURE:
#         {
#           "executiveSummary": {
#             "strategicSituation": "Clear, quantified problem statement with business impact",
#             "keyInsights": [
#               "Insight 1 with confidence level and supporting data count",
#               "Insight 2 addressing critic's main concerns",
#               "Insight 3 highlighting strategic opportunity/risk"
#             ],
#             "criticalDecisionFactors": [
#               "Factor 1: Timeline pressure vs implementation quality tradeoff",
#               "Factor 2: Technical capability constraints and mitigation options",
#               "Factor 3: Budget optimization vs strategic value creation"
#             ],
#             "strategicRecommendation": "Clear, actionable primary recommendation with rationale",
#             "confidenceStatement": "Overall confidence with specific strengths and limitations"
#           },
#           "strategicOptions": [
#             {
#               "rank": 1,
#               "strategy": "Hybrid Progressive Implementation",
#               "compositeScore": calculated_weighted_score,
#               "strategicRationale": "Why this approach best fits strategic context and constraints",
#               "scoreBreakdown": {
#                 "marketViability": "9.2/10 - Multiple validation sources confirm approach",
#                 "technicalFeasibility": "8.8/10 - Well within team capabilities with support",
#                 "implementationRisk": "7.5/10 - Managed through phased approach",
#                 "financialReturn": "9.0/10 - Strong ROI with conservative assumptions",
#                 "strategicAlignment": "9.5/10 - Perfect fit for growth stage and capabilities"
#               },
#               "confidenceAnalysis": {
#                 "overallConfidence": "HIGH - Validated across multiple dimensions",
#                 "strengthsOfEvidence": ["Market data from X sources", "Y successful case studies", "Critic validation passed"],
#                 "weaknessesOfEvidence": ["Limited long-term data", "Some vendor-provided metrics"],
#                 "criticAddressedConcerns": "Timeline conservatism, ROI assumption validation, risk mitigation planning"
#               },
#               "strategicAdvantages": [
#                 "Immediate capability gain while building long-term automation competency",
#                 "Risk diversification across multiple implementation approaches",
#                 "Learning and adaptation opportunities throughout implementation",
#                 "Competitive differentiation through operational efficiency"
#               ],
#               "implementationRoadmap": {
#                 "phase1": {
#                   "duration": "Weeks 1-4",
#                   "objectives": ["Immediate relief", "Learning foundation"],
#                   "actions": ["Deploy outsourcing solution", "Begin automation pilot"],
#                   "successMetrics": ["50% workload relief", "Pilot automation functioning"],
#                   "investmentRequired": "$X",
#                   "riskLevel": "LOW - Proven approaches"
#                 },
#                 "phase2": {
#                   "duration": "Months 2-6",
#                   "objectives": ["Scale automation", "Optimize hybrid model"],
#                   "actions": ["Expand AI capabilities", "Refine outsourcing scope"],
#                   "successMetrics": ["70% automation coverage", "Cost reduction targets met"],
#                   "investmentRequired": "$Y",
#                   "riskLevel": "MEDIUM - Scaling challenges possible"
#                 },
#                 "phase3": {
#                   "duration": "Months 6-12",
#                   "objectives": ["Full optimization", "Strategic capability"],
#                   "actions": ["Advanced automation features", "Knowledge transfer"],
#                   "successMetrics": ["Target cost structure achieved", "Internal competency built"],
#                   "investmentRequired": "$Z",
#                   "riskLevel": "LOW - Incremental improvements"
#                 }
#               }
#             }
#           ],
#           "decisionMatrix": {
#             "criteriaWeighting": {
#               "timelineUrgency": "25% - #{@form_data['timeline']} requirement drives prioritization",
#               "budgetOptimization": "20% - #{@form_data['budget_range']} constraint shapes options",
#               "riskTolerance": "20% - #{@form_data['technical_expertise']} team capability affects risk",
#               "strategicValue": "20% - Long-term competitive positioning",
#               "implementationFeasibility": "15% - Practical execution considerations"
#             },
#             "optionComparison": "Structured comparison across all evaluated options",
#             "sensitivityAnalysis": {
#               "mostSensitiveTo": "Implementation timeline assumptions",
#               "leastSensitiveTo": "Minor cost variations",
#               "breakingPoints": "Scenarios where recommendation would change"
#             }
#           },
#           "strategicRecommendations": {
#             "immediate": {
#               "nextSteps": ["Action 1 with timeline", "Action 2 with resource requirement"],
#               "decisionPoints": ["What to decide by when", "Success/failure criteria"],
#               "resourceAllocation": "Specific budget and team allocation guidance"
#             },
#             "mediumTerm": {
#               "capabilities": "Strategic capabilities to develop",
#               "partnerships": "Key relationships to establish",
#               "infrastructure": "Technology foundation to build"
#             },
#             "longTerm": {
#               "vision": "End-state strategic position",
#               "competencies": "Core competencies to develop",
#               "optionality": "Future strategic options this creates"
#             }
#           },
#           "riskManagement": {
#             "criticValidatedRisks": "Key risks identified and validated by critic analysis",
#             "mitigationStrategies": "Specific, actionable risk mitigation approaches",
#             "contingencyPlans": "What to do if primary strategy encounters obstacles",
#             "monitoringFramework": "KPIs and checkpoints for early risk detection"
#           },
#           "confidenceStatement": "Based on X data sources, Y validation methods, and critic review. High confidence in near-term recommendations, medium confidence in 6+ month projections. Key assumptions clearly identified and sensitivity tested."
#         }

#         SYNTHESIS QUALITY REQUIREMENTS:
#         - Integrate critic feedback explicitly into recommendations
#         - Provide specific confidence levels for each major conclusion
#         - Address conflicting analyses with clear resolution rationale
#         - Include sensitivity analysis for key assumptions
#         - Offer contingency strategies for different scenarios
#         - Ensure recommendations are actionable with clear next steps
#         - Balance optimism with realistic risk assessment
#         - Consider both immediate needs and long-term strategic positioning
#       PROMPT
#     end

#     private

#     def determine_synthesis_strategy
#       strategy = []

#       # Timeline-driven strategy
#       case @form_data['timeline']
#       when 'asap'
#         strategy << "URGENCY-DRIVEN SYNTHESIS: Prioritize immediate relief with parallel long-term building"
#       when 'exploring'
#         strategy << "EXPLORATION-ORIENTED: Focus on strategic optionality and learning opportunities"
#       else
#         strategy << "BALANCED APPROACH: Optimize for both immediate needs and strategic positioning"
#       end

#       # Budget-driven considerations
#       case @form_data['budget_range']
#       when '0-2000'
#         strategy << "BUDGET-CONSTRAINED: Maximize value within tight financial constraints"
#       when '20000+'
#         strategy << "INVESTMENT-ENABLED: Consider comprehensive strategic solutions"
#       end

#       # Team capability considerations
#       strategy << "CAPABILITY ALIGNMENT: Match solutions to #{@form_data['technical_expertise']} team capabilities"

#       strategy.join("\n")
#     end

#     def build_decision_framework
#       framework = []

#       # Critical success factors based on context
#       framework << "SUCCESS FACTORS:"
#       framework << "- Speed to value given #{@form_data['timeline']} timeline"
#       framework << "- Risk management for #{@form_data['technical_expertise']} team"
#       framework << "- Scalability for #{@form_data['team_size']} organization"

#       # Decision criteria weighting
#       framework << "\nDECISION WEIGHTS:"
#       if @form_data['timeline'] == 'asap'
#         framework << "- Implementation Speed: 35%"
#         framework << "- Financial ROI: 25%"
#         framework << "- Risk Level: 25%"
#         framework << "- Strategic Value: 15%"
#       else
#         framework << "- Financial ROI: 30%"
#         framework << "- Strategic Value: 25%"
#         framework << "- Implementation Speed: 25%"
#         framework << "- Risk Level: 20%"
#       end

#       framework.join("\n")
#     end

#     def identify_strategic_context
#       # Determine strategic context for targeted searches
#       if @form_data['team_size'] == '1'
#         'solo entrepreneur automation strategy'
#       elsif @form_data['business_type'] == 'SaaS B2B'
#         'B2B SaaS operational efficiency'
#       else
#         "#{@form_data['business_type']} digital transformation"
#       end
#     end

#     def generate_synthesis_specific_searches
#       searches = []

#       # Strategic context research
#       if @form_data['timeline'] == 'asap'
#         searches << "5. \"rapid business automation deployment lessons learned\""
#       else
#         searches << "5. \"strategic automation roadmap #{@form_data['business_type']}\""
#       end

#       # Competitive intelligence
#       searches << "6. \"#{@form_data['business_type']} automation competitive advantage 2025\""

#       searches.join("\n")
#     end
#   end
# end
