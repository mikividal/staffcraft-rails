module AiAgents
  class MarketIntelligence < BaseAgent
    def build_prompt
      options_analysis = previous_result('Comprehensive Options Strategist')

      <<~PROMPT
        You are a senior market research analyst and financial strategist specializing in talent markets, compensation analysis, and ROI modeling.

        COMPLETE HIRING CONTEXT:
        Recommended Approach: #{options_analysis&.dig('executiveSummary', 'optimalApproach')}
        Role Analysis:
        - Position: #{form_context['role_type']}
        - Experience Level: #{form_context['experience_level']}
        - Key Skills: #{form_context['key_skills']}
        - Work Arrangement: #{form_context['work_arrangement']}
        - Budget Range: #{form_context['budget_range']}
        - Market: #{form_context['country']}

        FINANCIAL MODELING INPUTS:
        - Expected Outcomes: #{form_context['expected_outcome']}
        - KPIs: #{form_context['kpis']}
        - Process Volume: #{form_context['process_volume']}
        - Peak Times: #{form_context['peak_times']}
        - Current Subscriptions Cost: Programming: #{form_context['programming_subscriptions']}, AI: #{form_context['ai_subscriptions']}
        - Cloud Costs: #{form_context['cloud_subscriptions']}

        ORGANIZATIONAL CONTEXT:
        - Business Type: #{form_context['business_type']}
        - Team Size: #{form_context['team_size']}
        - Technical Expertise: #{form_context['technical_expertise']}
        - Current Challenges: #{form_context['current_challenges']}

        CONSTRAINT FACTORS FOR ROI:
        - IT Availability: #{form_context['it_team_availability']}
        - Implementation Capacity: #{form_context['implementation_capacity']}
        - Maintenance Capability: #{form_context['maintenance_capability']}
        - Change Management Capacity: #{form_context['change_management_capacity']}

        MISSION: Provide comprehensive market intelligence and advanced ROI analysis with detailed financial modeling.

        Provide detailed analysis in this JSON format:
        {
          "marketIntelligence": {
            "talentMarket": {
              "salaryBenchmarks": {
                "percentile10": "$X for #{form_context['experience_level']} #{form_context['role_type']} in #{form_context['country']}",
                "percentile25": "$X (below average)",
                "percentile50": "$X (market median)",
                "percentile75": "$X (above average)",
                "percentile90": "$X (top 10% of market)",
                "dataSource": "specific source for #{form_context['country']} market",
                "workArrangementImpact": "salary adjustment for #{form_context['work_arrangement']}",
                "skillPremium": "premium for #{form_context['key_skills']} skills"
              },
              "hiringMetrics": {
                "timeToHire": {
                  "industry_average": "X weeks for #{form_context['role_type']}",
                  "this_role_market": "X weeks for #{form_context['experience_level']} in #{form_context['country']}",
                  "constraint_adjusted": "X weeks considering #{form_context['implementation_capacity']}"
                },
                "candidateFlow": {
                  "applications_per_posting": "average for #{form_context['role_type']} #{form_context['work_arrangement']}",
                  "qualified_percentage": "X% meet #{form_context['key_skills']} requirements",
                  "constraint_impact": "how #{form_context['it_team_availability']} affects hiring process"
                }
              }
            },
            "automationMarket": {
              "technologyMaturity": "assessment for #{form_context['process_description']} automation",
              "costTrends": "pricing evolution for tools addressing #{form_context['process_volume']}",
              "adoptionRates": "X% of #{form_context['business_type']} companies have automated similar processes"
            }
          },
          "advancedROIAnalysis": {
            "recommendedApproachROI": {
              "investmentBreakdown": {
                "yearOne": {
                  "setupCosts": "$X including #{form_context['timeline']} timeline adjustments",
                  "operationalCosts": "$X optimizing current #{form_context['programming_subscriptions']} + #{form_context['ai_subscriptions']}",
                  "constraintCosts": "$X for working within #{form_context['implementation_capacity']}",
                  "totalInvestment": "$X"
                }
              },
              "benefitsProjection": {
                "quantifiableBenefits": {
                  "timeSavings": "$X annually from #{form_context['process_volume']} optimization",
                  "qualityImprovement": "$X value addressing #{form_context['current_challenges']}",
                  "scalabilityValue": "capacity to handle #{form_context['peak_times']} without proportional cost"
                }
              },
              "constraintAdjustedModeling": {
                "baseCase": "ROI assuming optimal implementation",
                "realisticCase": "ROI adjusted for #{form_context['implementation_capacity']} and #{form_context['change_management_capacity']}",
                "constraintImpact": "how #{form_context['it_team_availability']} and #{form_context['maintenance_capability']} affect returns"
              }
            },
            "budgetAlignmentAnalysis": {
              "userBudgetAssessment": "analysis of #{form_context['budget_range']} vs market realities",
              "optimalBudgetAllocation": "recommendation for #{form_context['budget_range']} distribution",
              "budgetConstraintImpact": "how budget affects option viability given #{form_context['country']} market"
            }
          }
        }
      PROMPT
    end
  end
end
