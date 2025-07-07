module AiAgents
  class ToolsResearcher < BaseAgent
    def build_prompt
      options_analysis = previous_result('Comprehensive Options Strategist')

      <<~PROMPT
        You are a senior technology architect and tools research expert with deep knowledge of automation platforms, AI tools, development frameworks, and integration technologies.

        TECHNOLOGY RESEARCH CONTEXT:
        Recommended Approach: #{options_analysis&.dig('executiveSummary', 'optimalApproach')}
        Process to Address: #{form_context['process_description']}

        COMPLETE CURRENT TECHNOLOGY STACK:
        - Programming Languages: #{form_context['programming_languages']}
        - Programming Subscriptions: #{form_context['programming_subscriptions']}
        - Databases: #{form_context['databases']}
        - Database Subscriptions: #{form_context['database_subscriptions']}
        - Cloud Providers: #{form_context['cloud_providers']}
        - Cloud Subscriptions/Costs: #{form_context['cloud_subscriptions']}
        - AI Tools Currently Used: #{form_context['ai_tools']}
        - AI Tool Subscriptions: #{form_context['ai_subscriptions']}

        TECHNICAL CONSTRAINTS (CRITICAL FOR TOOL SELECTION):
        - Technical Expertise Level: #{form_context['technical_expertise']}
        - IT Team Availability: #{form_context['it_team_availability']}
        - Implementation Capacity: #{form_context['implementation_capacity']}
        - Maintenance Capability: #{form_context['maintenance_capability']}
        - Integration Requirements: #{form_context['integration_requirements']}
        - Security Requirements: #{form_context['security_requirements']}

        BUSINESS REQUIREMENTS:
        - Budget Range: #{form_context['budget_range']}
        - Team Size: #{form_context['team_size']}
        - Process Volume: #{form_context['process_volume']}
        - Peak Times: #{form_context['peak_times']}
        - Timeline: #{form_context['timeline']}

        MISSION: Research and recommend specific tools that align with the optimal approach, considering ALL technical constraints and current infrastructure.

        Provide comprehensive research in this JSON format:
        {
          "recommendedToolstack": [
            {
              "toolName": "specific tool name",
              "category": "ai_platform/automation_tool/development_framework/integration_platform",
              "primaryUseCase": "specific function addressing #{form_context['process_description']}",
              "constraintCompatibility": {
                "technicalSkillMatch": "how this fits #{form_context['technical_expertise']}",
                "itSupportNeeded": "requirements vs #{form_context['it_team_availability']}",
                "maintenanceComplexity": "level vs #{form_context['maintenance_capability']}",
                "integrationFit": "compatibility with #{form_context['programming_languages']} and #{form_context['databases']}"
              },
              "pricingStructure": {
                "freeTier": "limitations and features",
                "paidTiers": [
                  {
                    "tierName": "tier name",
                    "monthlyPrice": "$X",
                    "features": ["feature1", "feature2"],
                    "limits": "usage limits for #{form_context['process_volume']}"
                  }
                ],
                "currentStackOptimization": "savings with #{form_context['programming_subscriptions']} and #{form_context['ai_subscriptions']}",
                "setupCosts": "$X implementation cost given #{form_context['implementation_capacity']}"
              },
              "performanceData": {
                "throughputCapacity": "requests/hour for #{form_context['process_volume']}",
                "accuracyMetrics": "documented accuracy for similar use cases",
                "scalingBehavior": "performance under #{form_context['peak_times']} load",
                "reliabilityStats": "uptime considering #{form_context['security_requirements']}"
              },
              "implementationAssessment": {
                "setupComplexity": "complexity level vs #{form_context['technical_expertise']}",
                "timeToImplement": "realistic timeline given #{form_context['implementation_capacity']}",
                "skillsRequired": "vs available #{form_context['internal_skills_available']}",
                "learningCurve": "time to proficiency for #{form_context['team_size']} team"
              },
              "constraintFitScore": 87,
              "recommendationStrength": "strongly_recommended/recommended/conditional/not_recommended"
            }
          ],
          "currentStackOptimization": {
            "programmingStackImprovements": "optimizations for #{form_context['programming_languages']} and #{form_context['programming_subscriptions']}",
            "aiToolsOptimization": "improvements for #{form_context['ai_tools']} and #{form_context['ai_subscriptions']}",
            "cloudOptimization": "efficiency gains for #{form_context['cloud_providers']} costing #{form_context['cloud_subscriptions']}",
            "integrationOpportunities": "synergies addressing #{form_context['integration_requirements']}"
          },
          "implementationStrategy": {
            "phase1": {
              "duration": "X weeks considering #{form_context['implementation_capacity']}",
              "tools": ["tools suitable for #{form_context['technical_expertise']}"],
              "constraintMitigation": "how to work within #{form_context['it_team_availability']}"
            },
            "costOptimization": {
              "yearOneTotal": "$X total cost with current stack optimization",
              "potentialSavings": "$X from optimizing #{form_context['programming_subscriptions']} + #{form_context['ai_subscriptions']}"
            }
          }
        }
      PROMPT
    end
  end
end
