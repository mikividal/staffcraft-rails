module AiAgents
  class InputEvaluator < BaseAgent
    def build_prompt
      options_analysis = previous_result('Comprehensive Options Strategist')

      <<~PROMPT
        You are a business requirements analyst specializing in evaluating user inputs against optimal solutions.

        COMPLETE USER INPUT ANALYSIS:
        Basic Information:
        - Process Description: "#{form_context['process_description']}"
        - Business Type: "#{form_context['business_type']}"
        - Company Website: "#{form_context['company_website']}"

        Hiring Analysis:
        - Current Challenges: "#{form_context['current_challenges']}"
        - Role Type: "#{form_context['role_type']}"
        - Experience Level: "#{form_context['experience_level']}"
        - Key Skills: "#{form_context['key_skills']}"
        - Budget Range: "#{form_context['budget_range']}"
        - Work Arrangement: "#{form_context['work_arrangement']}"

        Expected Outcomes:
        - Expected Outcome: "#{form_context['expected_outcome']}"
        - KPIs: "#{form_context['kpis']}"

        Current Tech Stack:
        - Programming Languages: "#{form_context['programming_languages']}"
        - Programming Subscriptions: "#{form_context['programming_subscriptions']}"
        - Databases: "#{form_context['databases']}"
        - Database Subscriptions: "#{form_context['database_subscriptions']}"
        - Cloud Providers: "#{form_context['cloud_providers']}"
        - Cloud Subscriptions: "#{form_context['cloud_subscriptions']}"
        - AI Tools: "#{form_context['ai_tools']}"
        - AI Subscriptions: "#{form_context['ai_subscriptions']}"

        Team & Process:
        - Team Size: "#{form_context['team_size']}"
        - Technical Expertise: "#{form_context['technical_expertise']}"
        - Automation Level: "#{form_context['automation_level']}"
        - Process Volume: "#{form_context['process_volume']}"
        - Peak Times: "#{form_context['peak_times']}"
        - Integration Requirements: "#{form_context['integration_requirements']}"

        Implementation Constraints:
        - IT Team Availability: "#{form_context['it_team_availability']}"
        - Implementation Capacity: "#{form_context['implementation_capacity']}"
        - Internal Skills Available: "#{form_context['internal_skills_available']}"
        - Maintenance Capability: "#{form_context['maintenance_capability']}"
        - Change Management Capacity: "#{form_context['change_management_capacity']}"
        - Operational Constraints: "#{form_context['operational_constraints']}"

        Additional Details:
        - Country: "#{form_context['country']}"
        - Timeline: "#{form_context['timeline']}"
        - Security Requirements: "#{form_context['security_requirements']}"
        - Additional Context: "#{form_context['additional_context']}"

        OPTIMAL SOLUTION CONTEXT:
        Recommended Approach: #{options_analysis&.dig('executiveSummary', 'optimalApproach')}
        Confidence Level: #{options_analysis&.dig('executiveSummary', 'confidenceLevel')}%

        MISSION: Evaluate input quality across ALL dimensions and provide specific improvement recommendations.

        Provide detailed evaluation in this JSON format:
        {
          "overallInputAssessment": {
            "overallScore": 78,
            "inputCompleteness": "X% of critical fields provided with sufficient detail",
            "strategicAlignment": "assessment of user thinking vs optimal approach",
            "gapAnalysis": "key differences between user assumptions and recommended solution"
          },
          "dimensionalScoring": {
            "processDefinition": {
              "score": 85,
              "providedInfo": "quality of process description",
              "strengthsAnalysis": "what was well defined",
              "weaknessesAnalysis": "missing elements in process definition",
              "improvementRecommendations": ["specific process clarification needed"]
            },
            "hiringApproach": {
              "score": 72,
              "roleDefinition": "assessment of #{form_context['role_type']} specification",
              "skillsAlignment": "how #{form_context['key_skills']} align with optimal approach",
              "experienceLevelFit": "appropriateness of #{form_context['experience_level']}",
              "budgetRealism": "reality check on #{form_context['budget_range']} for #{form_context['country']} market",
              "improvementRecommendations": ["role refinement needed", "skills adjustment suggested"]
            },
            "technicalContext": {
              "score": 45,
              "currentStackAssessment": "completeness of tech stack information",
              "integrationClarityScore": "clarity of #{form_context['integration_requirements']}",
              "infrastructureGaps": "missing technical details that limit analysis",
              "improvementRecommendations": ["technical details needed for better analysis"]
            },
            "constraintsAwareness": {
              "score": 58,
              "constraintCompleteness": "how well constraints were identified",
              "realismAssessment": "realistic understanding of #{form_context['it_team_availability']} and #{form_context['implementation_capacity']}",
              "impactOnSuccess": "how constraint gaps affect implementation probability",
              "improvementRecommendations": ["additional constraints to consider"]
            },
            "outcomeDefinition": {
              "score": 70,
              "outcomeClarity": "specificity of #{form_context['expected_outcome']}",
              "kpiMeasurability": "measurability of #{form_context['kpis']}",
              "timelineRealism": "appropriateness of #{form_context['timeline']} expectations",
              "improvementRecommendations": ["outcome clarification needed"]
            },
            "implementationReadiness": {
              "score": 62,
              "capacityRealism": "realistic assessment of #{form_context['implementation_capacity']}",
              "changeReadiness": "organizational readiness given #{form_context['change_management_capacity']}",
              "skillsGapAwareness": "understanding of #{form_context['internal_skills_available']} vs needs",
              "improvementRecommendations": ["readiness assessment improvements"]
            }
          },
          "optimizationRecommendations": {
            "immediateImprovements": [
              {
                "area": "role definition",
                "currentState": "user specified #{form_context['role_type']} with #{form_context['key_skills']}",
                "recommendedState": "optimized role definition for #{options_analysis&.dig('executiveSummary', 'optimalApproach')}",
                "actionSteps": ["specific steps to improve role definition"]
              }
            ],
            "strategicRefinements": [
              {
                "area": "approach alignment",
                "currentApproach": "user thinking toward hiring",
                "recommendedApproach": "alignment with #{options_analysis&.dig('executiveSummary', 'optimalApproach')}",
                "rationale": "why this approach is superior given constraints"
              }
            ]
          }
        }
      PROMPT
    end
  end
end
