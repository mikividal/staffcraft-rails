module AiAgents
  class OptionsStrategist < BaseAgent
    def build_prompt
      <<~PROMPT
        You are a world-class management consultant and staffing strategist with 20+ years experience analyzing business operations, team optimization, and automation strategies. You have access to extensive industry data and have advised Fortune 500 companies on similar decisions.

        COMPREHENSIVE SCENARIO ANALYSIS:
        Business Context: #{form_context['business_type']}
        Process Description: #{form_context['process_description']}
        Current Challenges: #{form_context['current_challenges']}
        Expected Outcomes: #{form_context['expected_outcome']}
        KPIs: #{form_context['kpis']}
        Process Volume: #{form_context['process_volume']}
        Peak Times: #{form_context['peak_times']}

        HIRING ANALYSIS CONTEXT:
        Role Type: #{form_context['role_type']}
        Experience Level: #{form_context['experience_level']}
        Key Skills Required: #{form_context['key_skills']}
        Budget Range: #{form_context['budget_range']}
        Work Arrangement: #{form_context['work_arrangement']}

        CURRENT INFRASTRUCTURE & CAPABILITIES:
        - Programming Stack: #{form_context['programming_languages']}
        - Programming Subscriptions: #{form_context['programming_subscriptions']}
        - AI Tools: #{form_context['ai_tools']}
        - AI Subscriptions: #{form_context['ai_subscriptions']}
        - Database Infrastructure: #{form_context['databases']} (Subscriptions: #{form_context['database_subscriptions']})
        - Cloud Infrastructure: #{form_context['cloud_providers']} (Costs: #{form_context['cloud_subscriptions']})
        - Team Size: #{form_context['team_size']}
        - Technical Expertise Level: #{form_context['technical_expertise']}
        - Current Automation Level: #{form_context['automation_level']}
        - Integration Requirements: #{form_context['integration_requirements']}

        CRITICAL CONSTRAINTS (UNCHANGEABLE REALITIES):
        - IT Team Availability: #{form_context['it_team_availability']}
        - Implementation Capacity: #{form_context['implementation_capacity']}
        - Internal Skills Available: #{form_context['internal_skills_available']}
        - Maintenance Capability: #{form_context['maintenance_capability']}
        - Change Management Capacity: #{form_context['change_management_capacity']}
        - Operational Constraints: #{form_context['operational_constraints']}
        - Security Requirements: #{form_context['security_requirements']}

        MARKET CONTEXT:
        - Country/Market: #{form_context['country']}
        - Timeline: #{form_context['timeline']}
        - Additional Context: #{form_context['additional_context']}

        MISSION: Conduct exhaustive analysis of ALL options (full hire, automation-only, hybrid solution, strategic outsourcing) using industry data, constraint analysis, and quantitative modeling. Determine the OPTIMAL approach with confidence scoring and detailed justification.

        Provide comprehensive analysis in this JSON format:
        {
          "executiveSummary": {
            "optimalApproach": "full_hire/automation_only/hybrid_solution/strategic_outsourcing",
            "confidenceLevel": 94,
            "constraintDrivenRationale": "detailed explanation of how constraints specifically drive this decision",
            "businessImpactForecast": "predicted business impact over 12-24 months",
            "riskAssessment": "comprehensive risk analysis",
            "alternativeRanking": ["option1", "option2", "option3", "option4"]
          },
          "quantitativeAnalysis": {
            "fullHire": {
              "viabilityScore": 85,
              "constraintCompatibility": "detailed assessment of fit with current constraints",
              "annualCostBreakdown": {
                "baseSalary": "$X based on market data for #{form_context['experience_level']} #{form_context['role_type']} in #{form_context['country']}",
                "benefits": "$X (Y% of salary)",
                "equipment": "$X",
                "training": "$X",
                "recruitment": "$X",
                "overhead": "$X",
                "totalAnnual": "$X"
              },
              "implementationTimeline": {
                "jobPosting": "X weeks based on #{form_context['role_type']} market",
                "screening": "X weeks considering #{form_context['experience_level']} requirements",
                "interviews": "X weeks",
                "onboarding": "X weeks to productivity given #{form_context['technical_expertise']} team level",
                "totalToValue": "X weeks total"
              },
              "capacityAnalysis": {
                "dailyTasks": "specific task capacity considering #{form_context['process_volume']}",
                "weeklyOutput": "quantified weekly deliverables",
                "qualityLevel": "expected quality percentage",
                "scalability": "ability to handle volume increases given #{form_context['peak_times']}"
              },
              "strengthsDetailed": ["specific advantage 1", "specific advantage 2", "specific advantage 3"],
              "limitationsDetailed": ["limitation considering #{form_context['it_team_availability']}", "limitation given #{form_context['change_management_capacity']}", "limitation based on #{form_context['maintenance_capability']}"]
            },
            "automationOnly": {
              "viabilityScore": 92,
              "constraintCompatibility": "detailed assessment considering #{form_context['technical_expertise']} and #{form_context['it_team_availability']}",
              "annualCostBreakdown": {
                "toolLicenses": "$X considering current #{form_context['ai_tools']} and #{form_context['programming_languages']}",
                "implementation": "$X based on #{form_context['implementation_capacity']}",
                "maintenance": "$X given #{form_context['maintenance_capability']}",
                "training": "$X for #{form_context['team_size']} team",
                "infrastructure": "$X optimization of current #{form_context['cloud_providers']}",
                "totalAnnual": "$X"
              },
              "implementationTimeline": {
                "toolSelection": "X weeks considering #{form_context['integration_requirements']}",
                "setup": "X weeks given #{form_context['it_team_availability']}",
                "integration": "X weeks with current #{form_context['programming_languages']} stack",
                "testing": "X weeks",
                "training": "X weeks for #{form_context['technical_expertise']} team",
                "totalToValue": "X weeks"
              },
              "strengthsDetailed": ["advantage considering #{form_context['process_volume']}", "benefit given #{form_context['automation_level']}", "strength with #{form_context['peak_times']}"],
              "limitationsDetailed": ["limitation with #{form_context['security_requirements']}", "constraint given #{form_context['operational_constraints']}"]
            },
            "hybridSolution": {
              "viabilityScore": 88,
              "hybridModel": {
                "humanComponent": "specific role definition considering #{form_context['budget_range']} and #{form_context['experience_level']}",
                "automationComponent": "specific automation scope using #{form_context['ai_tools']}",
                "synergies": "how components enhance each other given #{form_context['process_volume']}"
              },
              "constraintCompatibility": "assessment of managing both human and automation given #{form_context['change_management_capacity']}"
            },
            "strategicOutsourcing": {
              "viabilityScore": 75,
              "outsourcingModel": {
                "recommendedType": "freelancer/agency/specialized firm for #{form_context['role_type']}",
                "scopeDefinition": "specific work considering #{form_context['key_skills']}",
                "qualityControl": "oversight approach given #{form_context['operational_constraints']}"
              },
              "constraintCompatibility": "fit with #{form_context['change_management_capacity']} and management preferences"
            }
          },
          "constraintImpactMatrix": {
            "itAvailability": {
              "fullHire": "impact on hiring and onboarding given #{form_context['it_team_availability']}",
              "automation": "impact on tool implementation given current #{form_context['it_team_availability']}",
              "hybrid": "impact on coordinating both approaches",
              "outsourcing": "impact on vendor management"
            },
            "implementationCapacity": {
              "fullHire": "bandwidth assessment given #{form_context['implementation_capacity']}",
              "automation": "bandwidth for automation setup given #{form_context['implementation_capacity']}",
              "hybrid": "bandwidth for dual implementation",
              "outsourcing": "bandwidth for vendor coordination"
            },
            "skillsGaps": {
              "analysis": "gap between #{form_context['internal_skills_available']} and needed skills for each option"
            }
          },
          "eliminatedOptions": [
            {
              "option": "eliminated option name",
              "eliminationReason": "specific constraint that makes this impossible",
              "wouldRequire": "what would need to change to make this viable"
            }
          ]
        }
      PROMPT
    end
  end
end
