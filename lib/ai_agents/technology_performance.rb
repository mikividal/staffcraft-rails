# module AiAgents
#   class TechnologyPerformance < BaseAgent
#     def build_prompt
#       <<~PROMPT
#         <role>Senior technology architect and automation specialist with expertise in AI implementations, SaaS integrations, and performance optimization. You excel at identifying the right tool for specific technical contexts and predicting implementation challenges.</role>

#         <context_analysis>
#         Process: #{@form_data['process_description']}
#         Business: #{@form_data['business_type']}
#         Current Stack: #{@form_data['current_stack']}
#         Team Tech Level: #{@form_data['technical_expertise']}
#         Team Size: #{@form_data['team_size']}
#         Timeline: #{@form_data['timeline']}
#         Budget: #{@form_data['budget_range']}
#         </context_analysis>

#         <technical_assessment>
#         First, analyze the technical fit:

#         Stack Integration Needs: #{stack_integration_analysis}
#         Team Capability Match: #{team_capability_analysis}
#         Implementation Complexity: #{complexity_assessment}
#         </technical_assessment>

#         <targeted_searches>
#         Execute only relevant searches based on context (6-8 maximum):

#         1. STACK-SPECIFIC INTEGRATION:
#            #{stack_specific_searches}

#         2. TEAM-APPROPRIATE SOLUTIONS:
#            #{team_appropriate_searches}

#         3. PERFORMANCE VALIDATION:
#            #{performance_validation_searches}

#         4. REAL USER EXPERIENCES:
#            #{user_experience_searches}
#         </targeted_searches>

#         <output_requirements>
#         {
#           "technologyRankings": [
#             {
#               "solution": "specific_tool_name",
#               "score": float,
#               "confidence": "HIGH/MEDIUM/LOW",
#               "integrationFit": "#{@form_data['current_stack']} compatibility score",
#               "teamFit": "#{@form_data['technical_expertise']} team appropriateness",
#               "costs": {
#                 "setup": "$X,XXX - Source: [platform]",
#                 "monthly": "$XXX - Source: [official pricing]",
#                 "hidden": "$XXX - Source: [user reports]"
#               },
#               "performanceMetrics": {
#                 "accuracy": "XX% - Source: [case studies]",
#                 "speed": "X tasks/hour - Source: [benchmarks]",
#                 "reliability": "XX% uptime - Source: [SLA data]"
#               },
#               "realWorldReports": {
#                 "successStories": ["verified implementations"],
#                 "commonIssues": ["reported problems"],
#                 "workarounds": ["community solutions"]
#               }
#             }
#           ],
#           "implementationPath": {
#             "phase1": "immediate quick wins",
#             "phase2": "core automation deployment",
#             "phase3": "optimization and scaling",
#             "timelineRealistic": "based on #{@form_data['technical_expertise']} team capability"
#           },
#           "reasoningChain": [/* technical reasoning steps */],
#           "techStackSynergy": {
#             "existingLeverages": ["how current tools help"],
#             "gaps": ["what's missing"],
#             "conflicts": ["potential integration issues"]
#           }
#         }
#         </output_requirements>

#         <technical_excellence>
#         - Prioritize solutions that integrate well with #{@form_data['current_stack']}
#         - Match complexity to #{@form_data['technical_expertise']} team capability
#         - Consider #{@form_data['timeline']} constraints in recommendations
#         - Validate performance claims with real user data
#         </technical_excellence>
#       PROMPT
#     end

#     private

#     def stack_integration_analysis
#       stack = @form_data['current_stack']&.downcase || ""

#       if stack.include?('salesforce')
#         "Salesforce-native solutions prioritized, API integration requirements"
#       elsif stack.include?('shopify')
#         "Shopify app ecosystem focus, webhook compatibility needs"
#       elsif stack.include?('slack') && stack.include?('google')
#         "Google Workspace + Slack workflow integration critical"
#       else
#         "Platform-agnostic solutions, standard API integration approach"
#       end
#     end

#     def team_capability_analysis
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         "No-code/low-code solutions only, extensive vendor support required"
#       when 'basic'
#         "Point-and-click configuration, minimal coding acceptable"
#       when 'intermediate'
#         "API integrations feasible, custom scripting possible"
#       when 'advanced'
#         "Full custom development options, self-hosted solutions viable"
#       else
#         "Mixed capability team, hybrid approach needed"
#       end
#     end

#     def complexity_assessment
#       if @form_data['timeline'] == 'asap' && @form_data['technical_expertise'] == 'non-technical'
#         "Maximum simplicity required - SaaS-only solutions"
#       elsif @form_data['team_size'] == '1' || @form_data['team_size'] == '2-5'
#         "Limited maintenance capacity - managed solutions preferred"
#       else
#         "Standard implementation complexity acceptable"
#       end
#     end

#     def stack_specific_searches
#       stack = @form_data['current_stack']&.downcase || ""

#       if stack.include?('salesforce')
#         '"salesforce automation ' + @form_data['process_description'] + ' apps pricing reviews"'
#       elsif stack.include?('shopify')
#         '"shopify ' + @form_data['process_description'] + ' automation apps comparison"'
#       elsif stack.include?('zapier')
#         '"zapier ' + @form_data['process_description'] + ' automation templates cost"'
#       else
#         '"' + @form_data['process_description'] + ' automation API integration tools"'
#       end
#     end

#     def team_appropriate_searches
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         '"no-code ' + @form_data['process_description'] + ' automation drag drop"'
#       when 'basic'
#         '"low-code ' + @form_data['process_description'] + ' automation small team"'
#       when 'intermediate', 'advanced'
#         '"' + @form_data['process_description'] + ' automation framework comparison developer"'
#       else
#         '"' + @form_data['process_description'] + ' automation tools comparison"'
#       end
#     end

#     def performance_validation_searches
#       '"' + @form_data['process_description'] + ' automation accuracy benchmarks case studies"'
#     end

#     def user_experience_searches
#       '"site:reddit.com ' + @form_data['process_description'] + ' automation ' + @form_data['business_type'] + ' experience"'
#     end
#   end
# end

# module AiAgents
#   class TechnologyPerformance < BaseAgent
#     def token_limit
#       3000  # From our updated limits
#     end

#     def build_prompt
#       <<~PROMPT
#         You are a senior technology architect specializing in automation tools and integrations. You can only do web searches. *No hallucination* if any required context slot is blank, never invent.

#         CONTEXT:
#         CONTEXT:
#         #{data_quality_instructions}
#         #{handle_previous_failures}
#         #{form_context}

#         YOUR TASK:
#         Research and evaluate automation tools for #{@form_data['process_description']} that fit your current tech stack and team capabilities.

#         SEARCH PRIORITY:
#         1. "#{build_tool_search_query} pricing performance reviews 2025"
#         2. "#{@form_data['current_stack']} integration #{@form_data['process_description']} automation"
#         3. "#{team_capability_search} automation tools comparison"

#         #{output_format_instructions}

#         SPECIFIC DATA STRUCTURE for "specific_data":
#         ```json
#         {
#           "specific_data": {
#             "recommended_tool": {
#               "name": "Tool Name",
#               "monthly_cost": "$XXX",
#               "setup_cost": "$X,XXX",
#               "implementation_time": "X weeks",
#               "stack_compatibility": "HIGH/MEDIUM/LOW"
#             },
#             "performance_metrics": {
#               "accuracy": "XX%",
#               "speed": "X tasks/hour",
#               "reliability": "XX% uptime",
#               "user_satisfaction": "X.X/5 stars"
#             },
#             "team_fit": {
#               "technical_difficulty": "LOW/MEDIUM/HIGH",
#               "learning_curve": "X weeks",
#               "maintenance_required": "LOW/MEDIUM/HIGH",
#               "support_quality": "Rating based on reviews"
#             },
#             "integration_analysis": {
#               "current_stack_fit": "Specific compatibility details",
#               "additional_tools_needed": ["List if any"],
#               "potential_conflicts": ["List if any"],
#               "migration_complexity": "LOW/MEDIUM/HIGH"
#             },
#             "alternative_options": [
#               {
#                 "name": "Alternative Tool",
#                 "monthly_cost": "$XXX",
#                 "pros": "Main advantages",
#                 "cons": "Main disadvantages"
#               }
#             ]
#           }
#         }
#         ```

#         CRITICAL:
#         - Match tool complexity to team's #{@form_data['technical_expertise']} level
#         - Consider #{@form_data['current_stack']} integration requirements
#         - Factor in #{@form_data['timeline']} constraints
#         - Include real user feedback and performance data
#       PROMPT
#     end

#         private

#         # En technology_performance.rb - agrega al final de la clase
#     private

#     def respond_in_text_format?
#       true  # Solo este agente responderá en texto
#     end

#     def build_tool_search_query
#       process = @form_data['process_description'].to_s.downcase

#       if process.include?('customer support')
#         "customer service automation AI chatbot"
#       elsif process.include?('data entry')
#         "data entry automation OCR forms"
#       elsif process.include?('email')
#         "email automation response generation"
#       elsif process.include?('social media')
#         "social media automation scheduling content"
#       else
#         "#{@form_data['process_description']} automation tools"
#       end
#     end

#     def team_capability_search
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         "no-code drag drop"
#       when 'basic'
#         "low-code easy setup"
#       when 'intermediate', 'advanced'
#         "developer API custom"
#       else
#         "business user friendly"
#       end
#     end
#   end
# end

module AiAgents
  class TechnologyPerformance < BaseAgent
    def token_limit
      3000  # From our updated limits
    end

    def build_prompt
      <<~PROMPT
        You are a senior technology architect specializing in automation tools and integrations. You can only do web searches. *No hallucination* if any required context slot is blank, never invent.

        CONTEXT:
        CONTEXT:
        #{data_quality_instructions}
        #{handle_previous_failures}
        #{form_context}

        YOUR TASK:
        Research and evaluate automation tools for #{@form_data['process_description']} that fit your current tech stack and team capabilities.

        SEARCH PRIORITY:
        1. "#{build_tool_search_query} pricing performance reviews 2025"
        2. "#{@form_data['current_stack']} integration #{@form_data['process_description']} automation"
        3. "#{team_capability_search} automation tools comparison"

        #{output_format_instructions}

        CRITICAL:
        - Match tool complexity to team's #{@form_data['technical_expertise']} level
        - Consider #{@form_data['current_stack']} integration requirements
        - Factor in #{@form_data['timeline']} constraints
        - Include real user feedback and performance data
      PROMPT
    end

    private

    def build_tool_search_query
      process = @form_data['process_description'].to_s.downcase

      if process.include?('customer support')
        "customer service automation AI chatbot"
      elsif process.include?('data entry')
        "data entry automation OCR forms"
      elsif process.include?('email')
        "email automation response generation"
      elsif process.include?('social media')
        "social media automation scheduling content"
      else
        "#{@form_data['process_description']} automation tools"
      end
    end

    def team_capability_search
      case @form_data['technical_expertise']
      when 'non-technical'
        "no-code drag drop"
      when 'basic'
        "low-code easy setup"
      when 'intermediate', 'advanced'
        "developer API custom"
      else
        "business user friendly"
      end
    end

    # MODIFIED METHOD - Changed from JSON to text format
    def output_format_instructions
      <<~FORMAT
        CRITICAL RESPONSE INSTRUCTIONS:
        - DO NOT say "I will research" or "Okay" or acknowledge this request
        - DO NOT explain what you're going to do
        - START IMMEDIATELY with "## Executive Summary"
        - RESPOND ONLY in the exact structured format below
        - If truncated, continue exactly where you left off in your next response

        REQUIRED OUTPUT FORMAT - START WITH THIS EXACT LINE:

        ## Executive Summary
        [Your comprehensive 4-6 sentence analysis that provides substantial context, explains the significance of findings, discusses implications, and sets up the key discoveries. It should give readers a thorough understanding of what was analyzed, why it matters, and what the overall conclusions indicate about the subject matter.]

        ## Key Findings
        1. [Specific, detailed finding 1 with concrete data points and context]
        2. [Specific, detailed finding 2 with measurable outcomes or clear evidence]
        3. [Specific, detailed finding 3 with quantitative or qualitative insights]
        4. [Specific, detailed finding 4 with comparative analysis or trend identification]
        5. [Specific, detailed finding 5 with actionable intelligence or critical insights]

        ## Technology Recommendations
        **Recommended Tool:** [Tool Name]
        **Monthly Cost:** $XXX - Source: [platform]
        **Setup Cost:** $X,XXX - Source: [vendor quotes]
        **Implementation Time:** X weeks
        **Stack Compatibility:** HIGH/MEDIUM/LOW with #{@form_data['current_stack']}

        **Performance Metrics:**
        - Accuracy: XX% query resolution
        - Speed: X tasks/hour or instant responses
        - Reliability: XX% uptime
        - User Satisfaction: X.X/5 stars

        **Team Fit Analysis:**
        - Technical Difficulty: LOW/MEDIUM/HIGH for #{@form_data['technical_expertise']} team
        - Learning Curve: X weeks
        - Maintenance Required: LOW/MEDIUM/HIGH
        - Support Quality: [Description of vendor support]

        ## Integration Analysis
        **Current Stack Compatibility:** [Specific details about how it works with #{@form_data['current_stack']}]
        **Additional Tools Needed:** [List any required additional tools or none]
        **Potential Conflicts:** [Any integration issues or none identified]
        **Migration Complexity:** LOW/MEDIUM/HIGH

        ## Alternative Options
        1. **[Alternative Tool Name]** - $XXX/month
           - Pros: [Main advantages]
           - Cons: [Main disadvantages]

        2. **[Alternative Tool Name]** - $XXX/month
           - Pros: [Main advantages]
           - Cons: [Main disadvantages]

        ## Implementation Roadmap
        **Phase 1 (Weeks 1-2):** [Immediate setup steps and quick wins]
        **Phase 2 (Weeks 3-4):** [Integration, training, and deployment]
        **Phase 3 (Month 2+):** [Optimization, scaling, and advanced features]

        ## Data Sources
        [Complete list of specific URLs, documents, databases, or other sources used in the analysis. Only include public, human-readable URLs. Avoid redirect links from Google Vertex or internal APIs. Format each source with a title and a visible, verifiable URL.]

        ## Confidence Level
        HIGH/MEDIUM/LOW - [Justification for the confidence rating based on data quality, source reliability, and comprehensiveness of research. Explain what strengthens or weakens the confidence in these recommendations.]

        CRITICAL REQUIREMENTS:
        - Match tool complexity to team's #{@form_data['technical_expertise']} level
        - Consider #{@form_data['timeline']} urgency in implementation recommendations
        - Factor in #{@form_data['budget_range']} budget constraints
        - Include real user feedback and performance data with sources
        - Provide specific, actionable next steps
      FORMAT
    end
  end
end

# module AiAgents
#   class TechnologyPerformance < BaseAgent
#     def build_prompt
#       tech_focus = determine_tech_focus
#       complexity_level = assess_complexity_level

#       <<~PROMPT
#         You are a technology architecture expert with deep knowledge of automation tools, AI platforms, and integration complexity.

#         TECHNICAL ASSESSMENT:
#         #{form_context_summary}

#         TECHNOLOGY FOCUS AREAS:
#         #{tech_focus}

#         COMPLEXITY ASSESSMENT:
#         #{complexity_level}

#         EXPERT SEARCH STRATEGY (6-8 targeted searches):

#         PHASE 1: Core Technology Research (Always execute):
#         1. "#{identify_primary_tools} pricing comparison #{Date.current.year}"
#         2. "#{identify_primary_tools} implementation time #{@form_data['technical_expertise']} team"
#         3. "site:reddit.com #{identify_primary_tools} real experience #{@form_data['business_type']}"

#         PHASE 2: Integration & Performance (Choose based on stack):
#         #{generate_tech_specific_searches}

#         PHASE 3: User Experience Validation:
#         #{generate_user_validation_searches}

#         ADVANCED ANALYSIS FRAMEWORK:
#         For each technology solution, evaluate:

#         1. TECHNICAL FIT ANALYSIS:
#         - Compatibility with existing stack: #{@form_data['current_stack']}
#         - Team technical capability match: #{@form_data['technical_expertise']}
#         - Scalability for team size: #{@form_data['team_size']}

#         2. IMPLEMENTATION COMPLEXITY SCORING:
#         ```
#         Score = (Setup_Time * 0.3) + (Learning_Curve * 0.3) + (Integration_Effort * 0.4)
#         Where: 1-10 scale, 10 = most complex
#         ```

#         3. PERFORMANCE METRICS VALIDATION:
#         - Search for real user performance data
#         - Verify vendor claims with independent sources
#         - Calculate true total cost of ownership

#         OUTPUT SPECIFICATION:
#         {
#           "technologyRankings": [
#             {
#               "solution": "GPT-4 + Make.com Integration",
#               "score": calculated_composite_score,
#               "confidence": "HIGH - Multiple data sources confirm performance",
#               "technicalFit": {
#                 "stackCompatibility": "9/10 - Integrates with #{@form_data['current_stack']}",
#                 "teamSkillMatch": "7/10 - #{@form_data['technical_expertise']} team can handle",
#                 "scalabilityRating": "8/10 - Grows with #{@form_data['team_size']} team"
#               },
#               "performanceMetrics": {
#                 "throughput": "X tasks/hour - Source: Vendor docs + user reports",
#                 "accuracy": "Y% - Source: Independent benchmarks",
#                 "uptime": "Z% SLA - Source: Platform status page",
#                 "realWorldPerformance": "Community average: W% effectiveness"
#               },
#               "costs": {
#                 "setup": {
#                   "initial": "$X - Source: Agency quotes",
#                   "configuration": "$Y - Source: Time estimates",
#                   "training": "$Z - Source: Learning curve data"
#                 },
#                 "monthly": {
#                   "platform": "$X - Source: Official pricing",
#                   "apiUsage": "$Y for Z volume - Source: Usage calculators",
#                   "maintenance": "$W - Source: Market rates"
#                 }
#               },
#               "implementationComplexity": {
#                 "setupTime": "X weeks - Source: User reports",
#                 "learningCurve": "Y difficulty (1-10) - Source: Reviews",
#                 "integrationEffort": "Z hours - Source: Documentation",
#                 "complexityScore": calculated_score,
#                 "riskFactors": ["List specific risks found in research"]
#               },
#               "userExperience": {
#                 "redditSentiment": "Positive/Negative/Mixed with examples",
#                 "g2Reviews": "X.X/5 from Y reviews",
#                 "commonComplaints": ["List from research"],
#                 "successStories": ["List from research"]
#               }
#             }
#           ],
#           "reasoningChain": [
#             {
#               "step": 1,
#               "action": "Analyzed compatibility with existing tech stack",
#               "methodology": "Cross-referenced platform APIs with user stack",
#               "result": "High compatibility score due to X, Y, Z",
#               "confidence": "HIGH - Technical documentation verified"
#             }
#           ],
#           "dataQuality": {
#             "sourcesAnalyzed": number_of_sources,
#             "vendorDataVerified": true/false,
#             "independentReviewsFound": number,
#             "communityDataPoints": number,
#             "missingMetrics": ["What couldn't be verified"]
#           }
#         }

#         CRITICAL VALIDATION REQUIREMENTS:
#         - Cross-reference vendor claims with user experiences
#         - Calculate realistic implementation timelines for team skill level
#         - Verify pricing with multiple sources (hidden costs are common)
#         - Assess long-term viability and vendor stability
#         - Consider integration maintenance burden
#       PROMPT
#     end

#     private

#     def determine_tech_focus
#       focus_areas = []

#       # Process-specific technology
#       process = @form_data['process_description'].to_s.downcase
#       if process.include?('customer support')
#         focus_areas << "FOCUS: Conversational AI, ticketing system integrations, chatbot platforms"
#       elsif process.include?('data entry')
#         focus_areas << "FOCUS: OCR tools, form automation, data validation systems"
#       elsif process.include?('email')
#         focus_areas << "FOCUS: Email automation, inbox management, response generation"
#       elsif process.include?('social media')
#         focus_areas << "FOCUS: Content scheduling, social listening, engagement automation"
#       end

#       # Technical capability considerations
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         focus_areas << "CONSTRAINT: No-code platforms only (Zapier, Make.com, Bubble)"
#       when 'basic'
#         focus_areas << "OPTION: Low-code platforms (Airtable, Notion integrations)"
#       when 'advanced'
#         focus_areas << "OPPORTUNITY: Custom API development, cloud functions, containerization"
#       end

#       focus_areas.join("\n")
#     end

#     def assess_complexity_level
#       complexity_factors = []

#       # Stack complexity
#       if @form_data['current_stack'].present?
#         stack_count = @form_data['current_stack'].split(',').count
#         if stack_count > 5
#           complexity_factors << "HIGH COMPLEXITY: #{stack_count} existing tools require integration"
#         else
#           complexity_factors << "MEDIUM COMPLEXITY: #{stack_count} tools in current stack"
#         end
#       else
#         complexity_factors << "LOW COMPLEXITY: Greenfield implementation"
#       end

#       # Team capacity
#       case @form_data['team_size']
#       when '1'
#         complexity_factors << "CONSTRAINT: Solo operation - minimal maintenance capacity"
#       when '50+'
#         complexity_factors << "ADVANTAGE: Large team can handle complex implementations"
#       end

#       complexity_factors.join("\n")
#     end

#     def identify_primary_tools
#       # Determine most relevant tools based on process and tech level
#       process = @form_data['process_description'].to_s.downcase
#       tech_level = @form_data['technical_expertise']

#       if process.include?('customer support')
#         tech_level == 'non-technical' ? 'Intercom AI Zendesk Answer Bot' : 'GPT-4 API customer service'
#       elsif process.include?('data entry')
#         tech_level == 'non-technical' ? 'Zapier forms Airtable automation' : 'Python automation OCR tools'
#       elsif process.include?('email')
#         tech_level == 'non-technical' ? 'Mailchimp automation Gmail filters' : 'email API automation'
#       else
#         tech_level == 'non-technical' ? 'no-code automation tools' : 'AI automation platforms'
#       end
#     end

#     def generate_tech_specific_searches
#       searches = []

#       # Current stack integration searches
#       if @form_data['current_stack'].present?
#         stack_tools = @form_data['current_stack'].split(',').map(&:strip)
#         primary_tool = stack_tools.first
#         searches << "4. \"#{primary_tool} #{identify_primary_tools} integration tutorial\""

#         if stack_tools.length > 1
#           searches << "5. \"#{stack_tools.join(' ')} workflow automation best practices\""
#         end
#       end

#       # Technical level specific
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         searches << "6. \"no-code #{extract_key_process} automation success stories\""
#       when 'advanced'
#         searches << "6. \"API #{extract_key_process} automation architecture patterns\""
#       end

#       # Timeline pressure
#       if @form_data['timeline'] == 'asap'
#         searches << "7. \"quick deploy #{identify_primary_tools} setup time\""
#       end

#       searches.join("\n")
#     end

#     def generate_user_validation_searches
#       validations = []

#       validations << "\"site:g2.com #{identify_primary_tools} verified reviews 2024 2025\""
#       validations << "\"site:producthunt.com #{identify_primary_tools} maker comments\""

#       # Add specific platform validation
#       validations << "\"#{identify_primary_tools} #{@form_data['business_type']} case study results\""

#       validations.map.with_index(8) { |search, i| "#{i}. #{search}" }.join("\n")
#     end

#     def extract_key_process
#       process = @form_data['process_description'].to_s.downcase

#       if process.include?('customer support') || process.include?('tickets')
#         'customer service'
#       elsif process.include?('social media') || process.include?('content')
#         'content management'
#       elsif process.include?('data entry') || process.include?('invoice')
#         'data processing'
#       elsif process.include?('email') || process.include?('communication')
#         'email management'
#       else
#         'business process'
#       end
#     end
#   end
# end
