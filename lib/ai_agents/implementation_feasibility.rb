module AiAgents
  class ImplementationFeasibility < BaseAgent
    def build_prompt
      <<~PROMPT
        <role>Implementation consultant and project manager with 12+ years delivering automation projects. Expert in change management, team capacity planning, and realistic timeline estimation. Known for identifying hidden obstacles before they become blockers.</role>

        <feasibility_context>
        Team Profile: #{@form_data['team_size']} #{@form_data['technical_expertise']} team
        Timeline Pressure: #{@form_data['timeline']}
        Process: #{@form_data['process_description']}
        Current Tools: #{@form_data['current_stack']}
        Constraints: #{@form_data['constraints']}
        Business Type: #{@form_data['business_type']}
        </feasibility_context>

        <constraint_analysis>
        Critical Constraints:
        #{constraint_evaluation}

        Team Capacity Reality:
        #{team_capacity_reality}

        Implementation Complexity:
        #{implementation_complexity}
        </constraint_analysis>

        <strategic_searches>
        Target 6-8 specific searches for feasibility validation:

        1. TEAM-SPECIFIC IMPLEMENTATION DATA:
           #{team_specific_searches}

        2. TIMELINE REALITY CHECKS:
           #{timeline_reality_searches}

        3. CONSTRAINT-SPECIFIC CHALLENGES:
           #{constraint_specific_searches}

        4. SUCCESS/FAILURE PATTERNS:
           #{pattern_analysis_searches}
        </strategic_searches>

        <output_requirements>
        {
          "feasibilityRankings": [
            {
              "approach": "specific_implementation_path",
              "score": float,
              "confidence": "HIGH/MEDIUM/LOW",
              "timelineRealistic": {
                "kickoff": "X days - Source: [verified data]",
                "productive": "X weeks - Source: [case studies]",
                "optimized": "X months - Source: [experience reports]"
              },
              "teamFitAnalysis": {
                "skillGaps": ["specific skills needed"],
                "bandwidthReality": "hours/week required vs available",
                "learningCurve": "estimated ramp time for #{@form_data['technical_expertise']} team"
              },
              "constraintHandling": {
                "#{@form_data['constraints']}": "specific mitigation approach"
              },
              "riskFactors": [
                {
                  "risk": "specific implementation risk",
                  "probability": "HIGH/MEDIUM/LOW",
                  "impact": "specific consequence",
                  "mitigation": "practical solution"
                }
              ]
            }
          ],
          "implementationPath": {
            "prerequisites": ["must-haves before starting"],
            "phase1": "#{@form_data['timeline']} compatible first steps",
            "successMetrics": ["how to measure progress"],
            "escapeHatches": ["fallback options if it doesn't work"]
          },
          "reasoningChain": [/* implementation-focused reasoning */],
          "realityCheck": {
            "optimisticScenario": "best case timeline and effort",
            "realisticScenario": "probable timeline and effort",
            "pessimisticScenario": "worst case timeline and effort",
            "recommendation": "which scenario to plan for"
          }
        }
        </output_requirements>

        <implementation_wisdom>
        - Factor in #{@form_data['timeline']} urgency vs quality tradeoffs
        - Consider #{@form_data['team_size']} team's bandwidth realistically
        - Address #{@form_data['constraints']} as implementation blockers
        - Validate timelines with real user experiences, not vendor promises
        </implementation_wisdom>
      PROMPT
    end

    private

    def constraint_evaluation
      constraints = @form_data['constraints'] || ""

      if constraints.downcase.include?('compliance')
        "Compliance requirements will add 2-4 weeks to any automation project"
      elsif constraints.downcase.include?('security')
        "Security review processes will extend timeline significantly"
      elsif constraints.downcase.include?('budget')
        "Budget constraints limit solution options and support levels"
      elsif constraints.empty?
        "No specific constraints mentioned - standard implementation approach"
      else
        "Custom constraints: #{constraints} - need specific research"
      end
    end

    def team_capacity_reality
      case [@form_data['team_size'], @form_data['technical_expertise']]
      when ['1', _] || ['2-5', 'non-technical']
        "Severely limited - need fully managed solutions only"
      when [_, 'non-technical']
        "No technical implementation capacity - vendor dependency required"
      when ['2-5', 'basic'] || ['6-20', 'basic']
        "Limited capacity - simple implementations only, extensive support needed"
      when [_, 'intermediate'] || [_, 'advanced']
        "Sufficient technical capacity for moderate complexity implementations"
      else
        "Need detailed capacity assessment"
      end
    end

    def implementation_complexity
      if @form_data['timeline'] == 'asap' && @form_data['technical_expertise'] == 'non-technical'
        "HIGH RISK: Urgent timeline + non-technical team = recipe for failure"
      elsif @form_data['current_stack']&.split(',')&.length&.> 3
        "MODERATE: Complex stack integration required"
      else
        "STANDARD: Normal implementation complexity expected"
      end
    end

    def team_specific_searches
      '"' + @form_data['team_size'] + ' ' + @form_data['technical_expertise'] + ' team implement ' + @form_data['process_description'] + ' automation timeline"'
    end

    def timeline_reality_searches
      '"' + @form_data['process_description'] + ' automation implementation ' + @form_data['timeline'] + ' realistic timeline"'
    end

    def constraint_specific_searches
      if @form_data['constraints']&.length&.> 0
        '"' + @form_data['process_description'] + ' automation ' + @form_data['constraints'] + ' challenges"'
      else
        '"' + @form_data['process_description'] + ' automation implementation common problems"'
      end
    end

    def pattern_analysis_searches
      '"site:reddit.com ' + @form_data['process_description'] + ' automation failed implementation lessons"'
    end
  end
end
