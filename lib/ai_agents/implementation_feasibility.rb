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
      team_size = @form_data['team_size'] || '2-5'
      tech_level = @form_data['technical_expertise'] || 'basic'

      # Handle the complex condition first
      if ['2-5', '6-20'].include?(team_size) && tech_level == 'non-technical'
        return "No technical implementation capacity - vendor dependency required"
      end

      case [team_size, tech_level]
      when ['1', 'non-technical'], ['1', 'basic']
        "Severely limited - need fully managed solutions only"
      when ['2-5', 'basic'], ['6-20', 'basic']
        "Limited capacity - simple implementations only, extensive support needed"
      when [team_size, 'intermediate'], [team_size, 'advanced']
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

# module AiAgents
#   class ImplementationFeasibility < BaseAgent
#     def build_prompt
#       risk_assessment = analyze_implementation_risks
#       resource_constraints = assess_resource_constraints

#       <<~PROMPT
#         You are an implementation strategy expert specializing in technology adoption, change management, and realistic timeline assessment.

#         IMPLEMENTATION CONTEXT:
#         #{form_context_summary}

#         RISK ASSESSMENT:
#         #{risk_assessment}

#         RESOURCE CONSTRAINTS:
#         #{resource_constraints}

#         STRATEGIC SEARCH PROTOCOL (6-8 focused searches):

#         PHASE 1: Reality Check Searches (Critical for accurate assessment):
#         1. "#{@form_data['team_size']} team implement #{identify_solution_type} timeline"
#         2. "site:reddit.com #{identify_solution_type} implementation failed #{@form_data['business_type']}"
#         3. "#{@form_data['technical_expertise']} team #{identify_solution_type} learning curve"

#         PHASE 2: Success Pattern Analysis:
#         #{generate_success_pattern_searches}

#         PHASE 3: Constraint Validation:
#         #{generate_constraint_validation_searches}

#         EXPERT FEASIBILITY FRAMEWORK:
#         Evaluate each option across these dimensions:

#         1. IMPLEMENTATION COMPLEXITY MATRIX:
#         ```
#         Complexity = Technical_Difficulty + Change_Management + Resource_Demand

#         Technical_Difficulty (1-10):
#         - non-technical team: +3 penalty for any coding required
#         - Integration count: +1 per existing tool to integrate
#         - Custom development: +5 complexity points

#         Change_Management (1-10):
#         - Team size impact: 1-5 people = +2, 50+ people = +5
#         - Process change scope: minor=+1, major=+4

#         Resource_Demand (1-10):
#         - Setup time: <1 week=1, >1 month=8
#         - Ongoing maintenance: <2 hrs/week=1, >10 hrs/week=7
#         ```

#         2. SUCCESS PROBABILITY CALCULATION:
#         Base on real implementation data from searches.

#         3. TIMELINE REALITY TESTING:
#         Cross-reference vendor claims with user experiences.

#         REQUIRED OUTPUT STRUCTURE:
#         {
#           "feasibilityRankings": [
#             {
#               "approach": "somewhere_outsourcing",
#               "score": calculated_score,
#               "confidence": "HIGH - Based on X verified implementations",
#               "complexityAnalysis": {
#                 "technicalDifficulty": "2/10 - Vendor handles all technical aspects",
#                 "changeManagement": "3/10 - Minimal process disruption required",
#                 "resourceDemand": "1/10 - 2-4 hours setup, minimal ongoing management",
#                 "totalComplexity": calculated_total,
#                 "comparedToAlternatives": "60% less complex than AI implementation"
#               },
#               "timelineAnalysis": {
#                 "vendorClaim": "24-48 hours to productivity",
#                 "userReality": "2-5 days based on Y Reddit experiences",
#                 "confidenceInTimeline": "HIGH - Consistent user reports",
#                 "criticalPath": ["Post requirement", "Developer selection", "Kickoff", "First delivery"],
#                 "riskFactors": ["Developer quality variance", "Communication overhead"]
#               },
#               "successProbability": {
#                 "percentage": "85% - Based on Z successful implementations",
#                 "successFactors": ["Clear requirements", "Good communication", "Realistic expectations"],
#                 "failureFactors": ["Vague requirements", "Unrealistic timelines", "Poor vendor selection"],
#                 "mitigationStrategies": ["Detailed brief", "Trial period", "Milestone structure"]
#               },
#               "resourceRequirements": {
#                 "humanTime": {
#                   "setup": "4-8 hours total",
#                   "ongoing": "2-4 hours/week management",
#                   "teamMemberInvolvement": "1 person primary, 0.5 others"
#                 },
#                 "financialCommitment": {
#                   "minimumViable": "$2,000 first month",
#                   "rampUp": "$4,000-8,000/month steady state",
#                   "terminationCost": "1 week notice"
#                 },
#                 "skillRequirements": {
#                   "required": ["Clear communication", "Basic project management"],
#                   "helpful": ["Previous outsourcing experience"],
#                   "notRequired": ["Technical skills", "Development knowledge"]
#                 }
#               },
#               "constraintFit": {
#                 "#{@form_data['timeline']}Timeline": "EXCELLENT - Immediate relief possible",
#                 "#{@form_data['team_size']}TeamSize": "GOOD - Scales with team growth",
#                 "#{@form_data['technical_expertise']}TechLevel": "PERFECT - No technical skills required",
#                 "budgetAlignment": "FITS - Within #{@form_data['budget_range']} range"
#               }
#             }
#           ],
#           "reasoningChain": [
#             {
#               "step": 1,
#               "action": "Analyzed team constraints and capability gaps",
#               "sources": ["Form data", "Industry benchmarks for #{@form_data['team_size']} teams"],
#               "analysis": "Team has X constraints, Y capabilities, Z gaps",
#               "confidence": "HIGH - Direct user input"
#             },
#             {
#               "step": 2,
#               "action": "Researched real implementation experiences",
#               "sources": ["Reddit posts", "G2 reviews", "Case studies"],
#               "findings": "X% success rate, Y average timeline, Z common issues",
#               "confidence": "MEDIUM - Sample size limitations"
#             }
#           ],
#           "implementationRecommendation": {
#             "preferredApproach": "Start with lowest-risk option",
#             "riskMitigation": "Parallel evaluation + backup plans",
#             "successMetrics": ["Week 1: X", "Month 1: Y", "Month 3: Z"],
#             "decisionFramework": "Choose based on urgency vs complexity tolerance"
#           }
#         }

#         CRITICAL VALIDATION POINTS:
#         - Verify vendor timelines with user experiences (not marketing claims)
#         - Account for team learning curves and adoption resistance
#         - Consider hidden implementation costs (integration, training, maintenance)
#         - Assess realistic ongoing resource requirements
#         - Evaluate reversibility if solution doesn't work
#         - Factor in opportunity cost of delayed implementation
#       PROMPT
#     end

#     private

#     def analyze_implementation_risks
#       risks = []

#       # Technical risks
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         risks << "HIGH RISK: No internal technical support for troubleshooting"
#         risks << "MITIGATION NEED: Fully managed solutions or strong vendor support"
#       when 'basic'
#         risks << "MEDIUM RISK: Limited troubleshooting capability"
#       when 'advanced'
#         risks << "LOW RISK: Strong technical foundation for implementation"
#       end

#       # Timeline risks
#       if @form_data['timeline'] == 'asap'
#         risks << "PRESSURE RISK: Urgent timeline may lead to poor solution selection"
#         risks << "RECOMMENDATION: Favor proven, quick-deploy solutions"
#       end

#       # Resource risks
#       case @form_data['team_size']
#       when '1'
#         risks << "CAPACITY RISK: Single person managing implementation + ongoing operations"
#       when '50+'
#         risks << "COORDINATION RISK: Large team coordination overhead"
#       end

#       risks.join("\n")
#     end

#     def assess_resource_constraints
#       constraints = []

#       # Budget constraints
#       case @form_data['budget_range']
#       when '0-2000'
#         constraints << "BUDGET: Limited to low-cost solutions (<$2k/month)"
#         constraints << "FOCUS: Free/freemium tools, offshore talent, DIY approaches"
#       when '20000+'
#         constraints << "BUDGET: Enterprise budget available (>$20k/month)"
#         constraints << "OPPORTUNITY: Premium solutions, dedicated teams possible"
#       end

#       # Time constraints
#       constraints << "TIMELINE: #{@form_data['timeline']} urgency level"

#       # Skill constraints
#       constraints << "SKILLS: #{@form_data['technical_expertise']} technical capability"

#       constraints.join("\n")
#     end

#     def identify_solution_type
#       if @form_data['process_description'].to_s.downcase.include?('customer support')
#         'customer service automation'
#       elsif @form_data['technical_expertise'] == 'non-technical'
#         'no-code automation'
#       else
#         'AI automation'
#       end
#     end

#     def generate_success_pattern_searches
#       searches = []

#       # Success pattern research
#       searches << "4. \"#{@form_data['business_type']} #{identify_solution_type} success story\""

#       # Similar company research
#       searches << "5. \"#{@form_data['team_size']} team automation implementation best practices\""

#       # Timeline validation
#       if @form_data['timeline'] == 'asap'
#         searches << "6. \"fastest #{identify_solution_type} deployment #{@form_data['business_type']}\""
#       else
#         searches << "6. \"#{identify_solution_type} implementation checklist timeline\""
#       end

#       searches.join("\n")
#     end

#     def generate_constraint_validation_searches
#       validations = []

#       # Budget reality check
#       validations << "\"#{identify_solution_type} hidden costs #{@form_data['budget_range']}\""

#       # Technical level validation
#       validations << "\"#{@form_data['technical_expertise']} team manage #{identify_solution_type}\""

#       # Failure analysis
#       validations << "\"site:news.ycombinator.com #{identify_solution_type} implementation lessons\""

#       validations.map.with_index(7) { |search, i| "#{i}. #{search}" }.join("\n")
#     end
#   end
# end
