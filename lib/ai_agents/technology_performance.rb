module AiAgents
  class TechnologyPerformance < BaseAgent
    def build_prompt
      <<~PROMPT
        <role>Senior technology architect and automation specialist with expertise in AI implementations, SaaS integrations, and performance optimization. You excel at identifying the right tool for specific technical contexts and predicting implementation challenges.</role>

        <context_analysis>
        Process: #{@form_data['process_description']}
        Business: #{@form_data['business_type']}
        Current Stack: #{@form_data['current_stack']}
        Team Tech Level: #{@form_data['technical_expertise']}
        Team Size: #{@form_data['team_size']}
        Timeline: #{@form_data['timeline']}
        Budget: #{@form_data['budget_range']}
        </context_analysis>

        <technical_assessment>
        First, analyze the technical fit:

        Stack Integration Needs: #{stack_integration_analysis}
        Team Capability Match: #{team_capability_analysis}
        Implementation Complexity: #{complexity_assessment}
        </technical_assessment>

        <targeted_searches>
        Execute only relevant searches based on context (6-8 maximum):

        1. STACK-SPECIFIC INTEGRATION:
           #{stack_specific_searches}

        2. TEAM-APPROPRIATE SOLUTIONS:
           #{team_appropriate_searches}

        3. PERFORMANCE VALIDATION:
           #{performance_validation_searches}

        4. REAL USER EXPERIENCES:
           #{user_experience_searches}
        </targeted_searches>

        <output_requirements>
        {
          "technologyRankings": [
            {
              "solution": "specific_tool_name",
              "score": float,
              "confidence": "HIGH/MEDIUM/LOW",
              "integrationFit": "#{@form_data['current_stack']} compatibility score",
              "teamFit": "#{@form_data['technical_expertise']} team appropriateness",
              "costs": {
                "setup": "$X,XXX - Source: [platform]",
                "monthly": "$XXX - Source: [official pricing]",
                "hidden": "$XXX - Source: [user reports]"
              },
              "performanceMetrics": {
                "accuracy": "XX% - Source: [case studies]",
                "speed": "X tasks/hour - Source: [benchmarks]",
                "reliability": "XX% uptime - Source: [SLA data]"
              },
              "realWorldReports": {
                "successStories": ["verified implementations"],
                "commonIssues": ["reported problems"],
                "workarounds": ["community solutions"]
              }
            }
          ],
          "implementationPath": {
            "phase1": "immediate quick wins",
            "phase2": "core automation deployment",
            "phase3": "optimization and scaling",
            "timelineRealistic": "based on #{@form_data['technical_expertise']} team capability"
          },
          "reasoningChain": [/* technical reasoning steps */],
          "techStackSynergy": {
            "existingLeverages": ["how current tools help"],
            "gaps": ["what's missing"],
            "conflicts": ["potential integration issues"]
          }
        }
        </output_requirements>

        <technical_excellence>
        - Prioritize solutions that integrate well with #{@form_data['current_stack']}
        - Match complexity to #{@form_data['technical_expertise']} team capability
        - Consider #{@form_data['timeline']} constraints in recommendations
        - Validate performance claims with real user data
        </technical_excellence>
      PROMPT
    end

    private

    def stack_integration_analysis
      stack = @form_data['current_stack']&.downcase || ""

      if stack.include?('salesforce')
        "Salesforce-native solutions prioritized, API integration requirements"
      elsif stack.include?('shopify')
        "Shopify app ecosystem focus, webhook compatibility needs"
      elsif stack.include?('slack') && stack.include?('google')
        "Google Workspace + Slack workflow integration critical"
      else
        "Platform-agnostic solutions, standard API integration approach"
      end
    end

    def team_capability_analysis
      case @form_data['technical_expertise']
      when 'non-technical'
        "No-code/low-code solutions only, extensive vendor support required"
      when 'basic'
        "Point-and-click configuration, minimal coding acceptable"
      when 'intermediate'
        "API integrations feasible, custom scripting possible"
      when 'advanced'
        "Full custom development options, self-hosted solutions viable"
      else
        "Mixed capability team, hybrid approach needed"
      end
    end

    def complexity_assessment
      if @form_data['timeline'] == 'asap' && @form_data['technical_expertise'] == 'non-technical'
        "Maximum simplicity required - SaaS-only solutions"
      elsif @form_data['team_size'] == '1' || @form_data['team_size'] == '2-5'
        "Limited maintenance capacity - managed solutions preferred"
      else
        "Standard implementation complexity acceptable"
      end
    end

    def stack_specific_searches
      stack = @form_data['current_stack']&.downcase || ""

      if stack.include?('salesforce')
        '"salesforce automation ' + @form_data['process_description'] + ' apps pricing reviews"'
      elsif stack.include?('shopify')
        '"shopify ' + @form_data['process_description'] + ' automation apps comparison"'
      elsif stack.include?('zapier')
        '"zapier ' + @form_data['process_description'] + ' automation templates cost"'
      else
        '"' + @form_data['process_description'] + ' automation API integration tools"'
      end
    end

    def team_appropriate_searches
      case @form_data['technical_expertise']
      when 'non-technical'
        '"no-code ' + @form_data['process_description'] + ' automation drag drop"'
      when 'basic'
        '"low-code ' + @form_data['process_description'] + ' automation small team"'
      when 'intermediate', 'advanced'
        '"' + @form_data['process_description'] + ' automation framework comparison developer"'
      else
        '"' + @form_data['process_description'] + ' automation tools comparison"'
      end
    end

    def performance_validation_searches
      '"' + @form_data['process_description'] + ' automation accuracy benchmarks case studies"'
    end

    def user_experience_searches
      '"site:reddit.com ' + @form_data['process_description'] + ' automation ' + @form_data['business_type'] + ' experience"'
    end
  end
end
