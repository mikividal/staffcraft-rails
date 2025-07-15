module AiAgents
  class RoiBusinessImpact < BaseAgent
    def build_prompt
      <<~PROMPT
        <role>Senior financial analyst and business case developer with CPA background. Expert in automation ROI modeling, cost-benefit analysis, and business impact measurement. Known for conservative, realistic projections that CFOs trust.</role>

        <financial_context>
        Current Process: #{@form_data['process_description']}
        Business Scale: #{@form_data['business_type']} with #{@form_data['team_size']} team
        Budget Constraint: #{@form_data['budget_range']}
        Timeline Value: #{@form_data['timeline']}
        Role Economics: #{@form_data['role_type']} (#{@form_data['experience_level']})
        Market: #{@form_data['country']}
        </financial_context>

        <roi_methodology>
        Calculate ROI using verified market data:

        Baseline Costs: #{baseline_cost_factors}
        Opportunity Cost: #{opportunity_cost_analysis}
        Implementation Investment: #{implementation_investment_factors}
        Ongoing Operational: #{operational_cost_factors}
        </roi_methodology>

        <financial_searches>
        Target 6-8 searches for ROI validation (prioritize verified financial data):

        1. VERIFIED BASELINE COSTS:
           #{baseline_cost_searches}

        2. IMPLEMENTATION INVESTMENTS:
           #{implementation_cost_searches}

        3. OPERATIONAL SAVINGS:
           #{operational_savings_searches}

        4. ROI CASE STUDIES:
           #{roi_validation_searches}
        </financial_searches>

        <output_requirements>
        {
          "roiRankings": [
            {
              "option": "specific_financial_option",
              "score": float,
              "confidence": "HIGH/MEDIUM/LOW",
              "financialProjection": {
                "year1": {
                  "investment": "$X,XXX - Source: [verified data]",
                  "savings": "$X,XXX - Source: [case studies]",
                  "netROI": "XX% - Calculated",
                  "paybackMonths": "X months - Based on cashflow model"
                },
                "year2": {
                  "ongoingCosts": "$X,XXX - Source: [operational data]",
                  "cumulativeSavings": "$X,XXX - Projected",
                  "totalROI": "XX% - Cumulative"
                }
              },
              "businessImpact": {
                "efficiencyGains": "XX% improvement - Source: [benchmarks]",
                "qualityImprovements": "measurable quality metrics",
                "scalabilityFactor": "growth capacity multiplier",
                "riskReduction": "operational risk mitigation value"
              },
              "sensitivityAnalysis": {
                "bestCase": "optimistic scenario ROI",
                "realistic": "probable scenario ROI",
                "worstCase": "conservative scenario ROI",
                "breakEvenPoint": "minimum performance required"
              }
            }
          ],
          "opportunityCostAnalysis": {
            "delayingDecision": "cost of #{@form_data['timeline']} delay",
            "statusQuoRisk": "cost of doing nothing",
            "competitiveDisadvantage": "market positioning impact"
          },
          "reasoningChain": [/* financial reasoning steps */],
          "businessCase": {
            "executiveSummary": "CFO-ready ROI summary",
            "keyAssumptions": ["critical assumptions in financial model"],
            "riskFactors": ["financial risks and mitigations"],
            "recommendedAction": "specific next step with financial rationale"
          }
        }
        </output_requirements>

        <financial_rigor>
        - Use only verified salary and cost data with sources
        - Include all hidden costs (training, integration, maintenance)
        - Apply conservative assumptions for projections
        - Factor in #{@form_data['timeline']} urgency costs
        - Consider #{@form_data['budget_range']} budget constraints in all scenarios
        </financial_rigor>
      PROMPT
    end

    private

    def baseline_cost_factors
      if @form_data['timeline'] == 'asap'
        "Premium hiring costs, opportunity cost of delays, current inefficiency costs"
      else
        "Standard hiring costs, normal opportunity costs, current process costs"
      end
    end

    def opportunity_cost_analysis
      "Cost of #{@form_data['timeline']} delay in solving #{@form_data['process_description']} inefficiencies"
    end

    def implementation_investment_factors
      case @form_data['technical_expertise']
      when 'non-technical'
        "High vendor dependency costs, extensive training needs, ongoing support costs"
      when 'advanced'
        "Lower implementation costs, self-sufficiency benefits, faster deployment"
      else
        "Moderate implementation costs, mixed support needs"
      end
    end

    def operational_cost_factors
      "Ongoing licensing, maintenance, support, and scaling costs for #{@form_data['business_type']} context"
    end

    def baseline_cost_searches
      '"' + @form_data['role_type'] + ' total cost employment ' + @form_data['country'] + ' benefits taxes 2025"'
    end

    def implementation_cost_searches
      '"' + @form_data['process_description'] + ' automation implementation cost ' + @form_data['technical_expertise'] + ' team"'
    end

    def operational_savings_searches
      '"' + @form_data['process_description'] + ' automation ROI case study ' + @form_data['business_type'] + '"'
    end

    def roi_validation_searches
      '"site:reddit.com ' + @form_data['process_description'] + ' automation payback period real experience"'
    end
  end
end

# module AiAgents
#   class RoiBusinessImpact < BaseAgent
#     def build_prompt
#       financial_context = analyze_financial_context
#       roi_methodology = determine_roi_methodology

#       <<~PROMPT
#         You are a financial analyst and business strategist specializing in automation ROI, total cost of ownership, and business impact assessment.

#         FINANCIAL ANALYSIS CONTEXT:
#         #{form_context_summary}

#         FINANCIAL FRAMEWORK:
#         #{financial_context}

#         ROI METHODOLOGY:
#         #{roi_methodology}

#         EXPERT FINANCIAL SEARCH STRATEGY (6-8 targeted searches):

#         PHASE 1: Cost Foundation (Essential baseline data):
#         1. "#{@form_data['role_type']} total employment cost #{@form_data['country']} benefits taxes"
#         2. "#{identify_automation_category} total cost ownership ROI studies"
#         3. "#{@form_data['business_type']} automation savings case studies"

#         PHASE 2: ROI Validation & Benchmarking:
#         #{generate_roi_validation_searches}

#         PHASE 3: Risk-Adjusted Returns:
#         #{generate_risk_analysis_searches}

#         ADVANCED ROI CALCULATION FRAMEWORK:

#         1. COMPREHENSIVE COST MODELING:
#         ```
#         Total_Cost = Direct_Costs + Indirect_Costs + Opportunity_Costs + Risk_Costs

#         Direct_Costs:
#         - Implementation: Setup, licensing, development
#         - Ongoing: Monthly fees, maintenance, support

#         Indirect_Costs:
#         - Team time: Training, management, troubleshooting
#         - Infrastructure: Additional tools, integrations

#         Opportunity_Costs:
#         - Implementation time: Revenue lost during setup
#         - Suboptimal period: Reduced efficiency during transition

#         Risk_Costs:
#         - Failure probability: Cost if implementation fails
#         - Switching costs: If solution needs replacement
#         ```

#         2. MULTI-SCENARIO ROI ANALYSIS:
#         Calculate best case, most likely, and worst case scenarios.

#         3. PAYBACK PERIOD VALIDATION:
#         Cross-reference calculated payback with real user experiences.

#         REQUIRED OUTPUT STRUCTURE:
#         {
#           "roiRankings": [
#             {
#               "option": "hybrid_outsourcing_then_automation",
#               "score": calculated_composite_score,
#               "confidence": "HIGH - Based on X verified case studies",
#               "roiAnalysis": {
#                 "scenarios": {
#                   "bestCase": {
#                     "yearOneROI": "340%",
#                     "paybackMonths": 2.1,
#                     "assumptions": ["Immediate productivity", "No implementation delays"]
#                   },
#                   "mostLikely": {
#                     "yearOneROI": "210%",
#                     "paybackMonths": 3.5,
#                     "assumptions": ["Standard adoption curve", "Minor delays"]
#                   },
#                   "worstCase": {
#                     "yearOneROI": "85%",
#                     "paybackMonths": 8.2,
#                     "assumptions": ["Implementation issues", "Learning curve delays"]
#                   }
#                 },
#                 "sensitivity": {
#                   "mostSensitiveTo": "Implementation timeline variance",
#                   "leastSensitiveTo": "Monthly cost fluctuations"
#                 }
#               },
#               "costBreakdown": {
#                 "baseline": {
#                   "currentSituation": {
#                     "description": "Current process cost/inefficiency",
#                     "monthlyCost": "$0 but growing backlog",
#                     "opportunityCost": "$X revenue risk - Source: Industry churn data",
#                     "scalingCost": "$Y if volume doubles - Calculated"
#                   }
#                 },
#                 "implementation": {
#                   "oneTime": {
#                     "setup": "$X - Source: Vendor quotes",
#                     "training": "$Y - Source: Time value estimates",
#                     "integration": "$Z - Source: Developer rates"
#                   },
#                   "ongoing": {
#                     "monthly": "$W - Source: Platform pricing",
#                     "management": "$V - Source: Time allocation",
#                     "scaling": "$U per unit growth - Calculated"
#                   }
#                 },
#                 "comparison": {
#                   "vsHiring": {
#                     "monthlyDifference": "$X savings",
#                     "yearOneSavings": "$Y total",
#                     "breakEvenPoint": "Month Z"
#                   },
#                   "vsStatus quo": {
#                     "efficiencyGain": "X% improvement",
#                     "capacityIncrease": "Y additional units handled",
#                     "qualityImprovement": "Z% reduction in errors"
#                   }
#                 }
#               },
#               "businessImpact": {
#                 "quantifiedBenefits": {
#                   "costReduction": "$X/month - Source: Calculation",
#                   "timeRecovered": "Y hours/week - Source: Process analysis",
#                   "qualityImprovement": "Z% error reduction - Source: Platform data",
#                   "scalingCapacity": "W% capacity increase - Source: Efficiency gains"
#                 },
#                 "strategicBenefits": {
#                   "marketResponse": "X% faster customer response",
#                   "competitiveAdvantage": "Cost structure improvement",
#                   "futureOptionality": "Platform for additional automation",
#                   "riskReduction": "Lower dependency on specific individuals"
#                 },
#                 "realUserOutcomes": {
#                   "averageROI": "X% based on Y case studies",
#                   "successRate": "Z% achieve positive ROI within 6 months",
#                   "commonSuccessFactors": ["Factor 1", "Factor 2"],
#                   "commonFailurePoints": ["Risk 1", "Risk 2"]
#                 }
#               }
#             }
#           ],
#           "reasoningChain": [
#             {
#               "step": 1,
#               "action": "Calculated true cost of current approach",
#               "methodology": "Opportunity cost + scaling cost + quality cost",
#               "data": "Form input + industry benchmarks",
#               "result": "$X monthly hidden cost identified",
#               "confidence": "MEDIUM - Based on industry averages"
#             },
#             {
#               "step": 2,
#               "action": "Researched real implementation costs",
#               "sources": ["Vendor pricing", "User forums", "Case studies"],
#               "validation": "Cross-referenced Y sources for accuracy",
#               "result": "Total implementation cost: $Z ± 20%",
#               "confidence": "HIGH - Multiple confirming sources"
#             }
#           ],
#           "investmentRecommendation": {
#             "recommendedStrategy": "Progressive implementation with milestone gates",
#             "initialInvestment": "$X for 3-month trial",
#             "scaleDecisionPoint": "Month 3 based on actual ROI data",
#             "riskMitigation": "Start small, measure, scale successful elements",
#             "successMetrics": ["Month 1: X% cost reduction", "Month 3: Y% efficiency gain"]
#           }
#         }

#         CRITICAL FINANCIAL VALIDATION REQUIREMENTS:
#         - Use conservative assumptions for projections
#         - Validate payback periods with real user data (not vendor claims)
#         - Include all hidden costs (training, maintenance, opportunity cost)
#         - Account for implementation risk and potential failures
#         - Consider scaling dynamics and future cost evolution
#         - Provide multiple scenario analysis for decision confidence
#         - Factor in reversibility costs if solution doesn't work
#       PROMPT
#     end

#     private

#     def analyze_financial_context
#       context = []

#       # Budget reality
#       case @form_data['budget_range']
#       when '0-2000'
#         context << "BUDGET CONSTRAINT: Sub-$2k budget requires high ROI solutions"
#         context << "FOCUS: Quick payback, minimal upfront investment"
#       when '20000+'
#         context << "BUDGET FLEXIBILITY: Enterprise budget allows strategic investments"
#         context << "FOCUS: Long-term value, comprehensive solutions"
#       else
#         context << "BUDGET BALANCE: Mid-market budget requires value optimization"
#       end

#       # Urgency impact on ROI
#       if @form_data['timeline'] == 'asap'
#         context << "URGENCY PREMIUM: Fast implementation may cost more but prevents revenue loss"
#       end

#       # Scale considerations
#       case @form_data['team_size']
#       when '1'
#         context << "SOLO OPERATION: ROI must account for single person productivity limits"
#       when '50+'
#         context << "ENTERPRISE SCALE: ROI benefits from economies of scale"
#       end

#       context.join("\n")
#     end

#     def determine_roi_methodology
#       methodology = []

#       # Process-specific ROI factors
#       process = @form_data['process_description'].to_s.downcase
#       if process.include?('customer support')
#         methodology << "ROI FACTORS: Response time improvement, ticket volume capacity, customer satisfaction"
#       elsif process.include?('data entry')
#         methodology << "ROI FACTORS: Error reduction, processing speed, labor cost savings"
#       else
#         methodology << "ROI FACTORS: Time savings, quality improvement, capacity increase"
#       end

#       # Timeline-adjusted ROI
#       if @form_data['timeline'] == 'asap'
#         methodology << "ROI URGENCY: Weight fast deployment benefits heavily"
#       else
#         methodology << "ROI PATIENCE: Can optimize for long-term value"
#       end

#       methodology.join("\n")
#     end

#     def identify_automation_category
#       process = @form_data['process_description'].to_s.downcase

#       if process.include?('customer support')
#         'customer service automation'
#       elsif process.include?('data entry')
#         'data processing automation'
#       elsif process.include?('email')
#         'email automation'
#       else
#         'business process automation'
#       end
#     end

#     def generate_roi_validation_searches
#       searches = []

#       # Industry ROI benchmarks
#       searches << "4. \"#{@form_data['business_type']} #{identify_automation_category} ROI benchmark study\""

#       # Real user ROI experiences
#       searches << "5. \"site:reddit.com #{identify_automation_category} ROI real numbers #{@form_data['team_size']}\""

#       # Failure cost analysis
#       searches << "6. \"#{identify_automation_category} implementation failure cost analysis\""

#       searches.join("\n")
#     end

#     def generate_risk_analysis_searches
#       searches = []

#       # Risk-adjusted returns
#       searches << "\"#{identify_automation_category} implementation risk factors #{@form_data['technical_expertise']}\""

#       # Market comparison
#       searches << "\"automation vs hiring ROI comparison #{@form_data['country']} #{Date.current.year}\""

#       searches.map.with_index(7) { |search, i| "#{i}. #{search}" }.join("\n")
#     end
#   end
# end
