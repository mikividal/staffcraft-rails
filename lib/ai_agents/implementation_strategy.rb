module AiAgents
  class ImplementationStrategy < BaseAgent
    def build_prompt
      options_analysis = previous_result('Comprehensive Options Strategist')

      <<~PROMPT
        You are a senior implementation consultant specializing in constraint-aware implementation planning.

        COMPLETE IMPLEMENTATION CONTEXT:
        Recommended Strategy: #{options_analysis&.dig('executiveSummary', 'optimalApproach')}
        Business Environment: #{form_context['business_type']}
        Process: #{form_context['process_description']}
        Current Challenges: #{form_context['current_challenges']}
        Timeline Preference: #{form_context['timeline']}

        ORGANIZATIONAL CONTEXT:
        - Team Size: #{form_context['team_size']}
        - Technical Expertise: #{form_context['technical_expertise']}
        - Current Automation: #{form_context['automation_level']}
        - Process Volume: #{form_context['process_volume']}
        - Peak Times: #{form_context['peak_times']}

        CRITICAL CONSTRAINTS (MUST BE RESPECTED):
        - IT Team Availability: #{form_context['it_team_availability']}
        - Implementation Capacity: #{form_context['implementation_capacity']}
        - Internal Skills: #{form_context['internal_skills_available']}
        - Maintenance Capability: #{form_context['maintenance_capability']}
        - Change Management Capacity: #{form_context['change_management_capacity']}
        - Operational Constraints: #{form_context['operational_constraints']}
        - Security Requirements: #{form_context['security_requirements']}

        MISSION: Create detailed, constraint-aware implementation plan that maximizes success probability.

        Provide comprehensive strategy in this JSON format:
        {
          "executionPlan": {
            "overallStrategy": {
              "approach": "implementation philosophy considering all constraints",
              "constraintOptimization": "how plan works within #{form_context['it_team_availability']}, #{form_context['implementation_capacity']}, #{form_context['change_management_capacity']}",
              "successProbability": "X% likelihood given constraints",
              "totalDuration": "X weeks realistic timeline considering #{form_context['timeline']}"
            },
            "phase1_foundation": {
              "duration": "X weeks considering #{form_context['implementation_capacity']}",
              "primaryObjectives": ["objectives achievable with #{form_context['technical_expertise']}"],
              "constraintConsiderations": ["how this works with #{form_context['it_team_availability']}", "accommodation for #{form_context['change_management_capacity']}"],
              "skillsLeveraged": "utilization of #{form_context['internal_skills_available']}"
            },
            "phase2_implementation": {
              "duration": "X weeks",
              "constraintMitigation": "strategies for #{form_context['maintenance_capability']} limitations",
              "operationalConsiderations": "working within #{form_context['operational_constraints']}"
            }
          },
          "resourcePlan": {
            "humanResources": {
              "projectLead": {
                "timeCommitment": "X% of role considering #{form_context['implementation_capacity']}",
                "constraintFit": "how this fits with available capacity"
              },
              "technicalLead": {
                "skillsRequired": "match with #{form_context['internal_skills_available']}",
                "constraintFit": "alignment with #{form_context['it_team_availability']}"
              }
            },
            "constraintWorkarounds": {
              "itAvailabilityWorkarounds": "strategies for limited #{form_context['it_team_availability']}",
              "skillsGapBridging": "how to bridge gaps in #{form_context['internal_skills_available']}",
              "capacityOptimization": "maximizing #{form_context['implementation_capacity']}"
            }
          },
          "riskManagement": {
            "constraintSpecificRisks": [
              {
                "risk": "risk from #{form_context['it_team_availability']} limitations",
                "mitigation": "specific strategy"
              },
              {
                "risk": "risk from #{form_context['change_management_capacity']} constraints",
                "mitigation": "change management approach"
              }
            ]
          }
        }
      PROMPT
    end
  end
end
