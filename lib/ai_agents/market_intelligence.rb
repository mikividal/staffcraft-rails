# module AiAgents
#   class MarketIntelligence < BaseAgent
#     def build_prompt
#       <<~PROMPT
#         <role>Expert market research analyst with 15+ years in talent acquisition, compensation analysis, and automation ROI. You have deep expertise in sourcing verified salary data, identifying reliable vendors, and conducting competitive analysis.</role>

#         <context_analysis>
#         Process: #{@form_data['process_description']}
#         Business: #{@form_data['business_type']}
#         Role: #{@form_data['role_type']} (#{@form_data['experience_level']})
#         Budget: #{@form_data['budget_range']}
#         Location: #{@form_data['country']}
#         Team: #{@form_data['team_size']} (#{@form_data['technical_expertise']})
#         Stack: #{@form_data['current_stack']}
#         Timeline: #{@form_data['timeline']}
#         Constraints: #{@form_data['constraints']}
#         </context_analysis>

#         <search_strategy>
#         Analyze the context and execute ONLY the most relevant searches (3-4 maximum):

#         1. SALARY INTELLIGENCE (always required):
#            - Primary: "#{@form_data['role_type']} total compensation #{@form_data['country']} 2025"
#           - Secondary: "#{@form_data['role_type']} salary benefits taxes cost #{@form_data['country']}"

#         2. CONDITIONAL AUTOMATION COSTS:
#            #{automation_search_logic}

#         3. CONDITIONAL OUTSOURCING:
#            #{outsourcing_search_logic}

#         4. VERIFICATION SOURCES:
#            #{verification_search_logic}
#         </search_strategy>

#         <output_requirements>
#         Return structured JSON with explicit reasoning chains:

#         {
#           "marketRankings": [
#             {
#               "option": "option_name",
#               "score": float,
#               "confidence": "HIGH/MEDIUM/LOW",
#               "monthlyCost": "$X,XXX - Source: [specific platform]",
#               "dataQuality": "HIGH/MEDIUM/LOW - [reasoning]",
#               "availability": "[timeline] - Source: [platform]",
#               "constraints": ["specific limitations for this context"]
#             }
#           ],
#           "reasoningChain": [
#             {
#               "step": 1,
#               "action": "[specific action taken]",
#               "source": "[exact source name]",
#               "result": "[quantified finding]",
#               "confidence": "HIGH/MEDIUM/LOW",
#               "contextRelevance": "[why this matters for their specific case]"
#             }
#           ],
#           "contextualInsights": {
#             "urgencyFactors": "[how #{@form_data['timeline']} affects recommendations]",
#             "teamConstraints": "[how #{@form_data['team_size']} #{@form_data['technical_expertise']} team affects options]",
#             "budgetFit": "[options within #{@form_data['budget_range']} range]"
#           },
#           "dataTransparency": {
#             "highConfidence": ["specific data points with strong verification"],
#             "assumptions": ["explicit assumptions made"],
#             "gaps": ["data not found despite searching"]
#           }
#         }
#         </output_requirements>

#         <quality_standards>
#         - Every cost figure must include source attribution
#         - Confidence levels must reflect actual data quality found
#         - Reasoning must be specific to their context, not generic
#         - Identify context-specific risks (e.g., hiring in #{@form_data['country']} market conditions)
#         </quality_standards>
#       PROMPT
#     end

#     private

#     def automation_search_logic
#       if @form_data['current_stack']&.downcase&.include?('salesforce')
#         '- "salesforce automation #{@form_data[\'process_description\']} pricing integration"'
#       elsif @form_data['current_stack']&.downcase&.include?('shopify')
#         '- "shopify #{@form_data[\'process_description\']} automation apps cost"'
#       elsif @form_data['business_type'] == 'SaaS B2B'
#         '- "saas #{@form_data[\'process_description\']} automation tools enterprise pricing"'
#       elsif @form_data['business_type'] == 'E-commerce'
#         '- "ecommerce #{@form_data[\'process_description\']} automation cost comparison"'
#       else
#         '- "#{@form_data[\'process_description\']} automation platform pricing 2025"'
#       end
#     end

#     def outsourcing_search_logic
#       if @form_data['timeline'] == 'asap'
#         '- "upwork toptal #{@form_data[\'role_type\']} immediate availability rates"'
#       elsif @form_data['budget_range'] == '0-2000'
#         '- "budget outsourcing #{@form_data[\'role_type\']} offshore rates quality"'
#       else
#         '- "premium outsourcing #{@form_data[\'role_type\']} #{@form_data[\'business_type\']} reviews"'
#       end
#     end

#     def verification_search_logic
#       if @form_data['business_type'] == 'SaaS B2B'
#         '- "site:reddit.com/r/saas #{@form_data[\'role_type\']} hiring vs automation experience"'
#       else
#         '- "site:reddit.com #{@form_data[\'business_type\']} #{@form_data[\'process_description\']} automation vs hiring"'
#       end
#     end
#   end
# end

# module AiAgents
#   class MarketIntelligence < BaseAgent
#     def token_limit
#       1200  # From our updated limits
#     end

#     def build_prompt
#       <<~PROMPT
#         You are an expert market research analyst specializing in talent costs vs automation solutions with web_search access. Find REAL salary, talent, AND automation cost data. You can only do web searches. *No hallucination* if any required context slot is blank, never invent.


#         CONTEXT:
#         #{data_quality_instructions}
#         #{handle_previous_failures}
#         #{form_context}

#         YOUR TASK:
#         Research and analyze the cost of hiring a #{@form_data['role_type']} vs automation solutions for #{@form_data['process_description']}.

#         REQUIRED SEARCHES:

#         1. CURRENT SALARIES + BENEFITS:
#         - "#{@form_data['role_type']} total compensation #{@form_data['country']} #{Date.current.year}"
#         - "True cost of employee calculator including benefits taxes"
#         - "#{@form_data['role_type']} turnover rate statistics"

#         2. AUTOMATION TOOL COSTS (EXPANDED):
#         - "Customer service automation platform pricing comparison"
#         - "AI chatbot pricing per conversation 2025"
#         - "#{@form_data['process_description']} automation tool costs"
#         - "site:g2.com pricing #{@form_data['process_description']} automation"
#         - "site:capterra.com cost comparison AI tools"

#         3. AI AGENT MARKETPLACES:
#         - "HuggingFace AI agents #{@form_data['process_description']}"
#         - "OpenAI GPT store agents #{@form_data['business_type']}"
#         - "Fixie AI agents marketplace pricing"
#         - "AutoGPT agents cost comparison"

#         4. OUTSOURCING DETAILED RATES:
#         - "Somewhere.com #{@form_data['role_type']} developer rates reviews"
#         - "site:reddit.com Somewhere.com experience #{@form_data['business_type']}"
#         - "Upwork vs Toptal vs Somewhere pricing #{@form_data['role_type']}"
#         - "site:producthunt.com Somewhere.com reviews"

#         5. COMMUNITY INSIGHTS (EXPANDED):
#         - "site:reddit.com/r/business #{@form_data['role_type']} hire or automate"
#         - "site:reddit.com hidden costs hiring #{@form_data['country']}"
#         - "site:teamblind.com #{@form_data['role_type']} compensation data"
#         - "site:news.ycombinator.com hiring vs automation debate"

#         6. ACADEMIC RESEARCH:
#         - "NBER automation vs employment papers"
#         - "site:scholar.google.com automation ROI studies"
#         - "MIT automation workforce impact research"

#         #{output_format_instructions}

#         SPECIFIC DATA STRUCTURE for "specific_data":
#         ```json
#         {
#           "specific_data": {
#             "hiring_option": {
#               "monthly_cost": "$X,XXX",
#               "total_first_year": "$XX,XXX",
#               "time_to_hire": "X weeks",
#               "market_availability": "HIGH/MEDIUM/LOW"
#             },
#             "automation_option": {
#               "monthly_cost": "$XXX",
#               "setup_cost": "$X,XXX",
#               "total_first_year": "$X,XXX",
#               "implementation_time": "X weeks"
#             },
#             "outsourcing_option": {
#               "monthly_cost": "$X,XXX",
#               "setup_time": "X weeks",
#               "total_first_year": "$XX,XXX",
#               "quality_risk": "HIGH/MEDIUM/LOW"
#             },
#             "top_recommendation": {
#               "option": "hiring/automation/outsourcing",
#               "reason": "Brief explanation",
#               "cost_advantage": "$X,XXX savings vs alternatives"
#             }
#           }
#         }
#         ```

#         CRITICAL: Include actual numbers with sources. If data isn't available, clearly state "Data not found" rather than making up numbers.
#       PROMPT
#     end
#   end
# end

module AiAgents
  class MarketIntelligence < BaseAgent
    def token_limit
      1200  # From our updated limits
    end

    def build_prompt
      <<~PROMPT
        You are an expert market research analyst specializing in talent costs vs automation solutions with web_search access. Find REAL salary, talent, AND automation cost data. You can only do web searches. *No hallucination* if any required context slot is blank, never invent.

        CONTEXT:
        #{data_quality_instructions}
        #{handle_previous_failures}
        #{form_context}

        YOUR TASK:
        Research and analyze the cost of hiring a #{@form_data['role_type']} vs automation solutions for #{@form_data['process_description']}.

        REQUIRED SEARCHES:

        1. CURRENT SALARIES + BENEFITS:
        - "#{@form_data['role_type']} total compensation #{@form_data['country']} #{Date.current.year}"
        - "True cost of employee calculator including benefits taxes"
        - "#{@form_data['role_type']} turnover rate statistics"

        2. AUTOMATION TOOL COSTS (EXPANDED):
        - "Customer service automation platform pricing comparison"
        - "AI chatbot pricing per conversation 2025"
        - "#{@form_data['process_description']} automation tool costs"
        - "site:g2.com pricing #{@form_data['process_description']} automation"
        - "site:capterra.com cost comparison AI tools"

        3. AI AGENT MARKETPLACES:
        - "HuggingFace AI agents #{@form_data['process_description']}"
        - "OpenAI GPT store agents #{@form_data['business_type']}"
        - "Fixie AI agents marketplace pricing"
        - "AutoGPT agents cost comparison"

        4. OUTSOURCING DETAILED RATES:
        - "Somewhere.com #{@form_data['role_type']} developer rates reviews"
        - "site:reddit.com Somewhere.com experience #{@form_data['business_type']}"
        - "Upwork vs Toptal vs Somewhere pricing #{@form_data['role_type']}"
        - "site:producthunt.com Somewhere.com reviews"

        5. COMMUNITY INSIGHTS (EXPANDED):
        - "site:reddit.com/r/business #{@form_data['role_type']} hire or automate"
        - "site:reddit.com hidden costs hiring #{@form_data['country']}"
        - "site:teamblind.com #{@form_data['role_type']} compensation data"
        - "site:news.ycombinator.com hiring vs automation debate"

        6. ACADEMIC RESEARCH:
        - "NBER automation vs employment papers"
        - "site:scholar.google.com automation ROI studies"
        - "MIT automation workforce impact research"

        #{output_format_instructions}

        CRITICAL: Include actual numbers with sources. If data isn't available, clearly state "Data not found" rather than making up numbers.
      PROMPT
    end

    private

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
        [Your comprehensive 4-6 sentence analysis that provides substantial context, explains the significance of findings, discusses implications, and sets up the key discoveries. It should give readers a thorough understanding of what was analyzed, why it matters, and what the overall conclusions indicate about the cost comparison between hiring vs automation vs outsourcing.]

        ## Key Findings
        1. [Specific, detailed finding 1 with concrete salary/cost data points and sources]
        2. [Specific, detailed finding 2 with measurable automation costs or hiring expenses with evidence]
        3. [Specific, detailed finding 3 with quantitative market insights and comparative analysis]
        4. [Specific, detailed finding 4 with outsourcing rates and trend identification]
        5. [Specific, detailed finding 5 with actionable intelligence or critical cost insights]

        ## Cost Analysis Breakdown

        ### Hiring Option
        **Monthly Cost:** $X,XXX - Source: [specific platform/study]
        **Total First Year:** $XX,XXX (including benefits, taxes, overhead)
        **Time to Hire:** X weeks
        **Market Availability:** HIGH/MEDIUM/LOW
        **Hidden Costs:** $X,XXX for recruiting, onboarding, benefits

        ### Automation Option
        **Monthly Cost:** $XXX - Source: [platform pricing]
        **Setup Cost:** $X,XXX - Source: [vendor quotes/research]
        **Total First Year:** $X,XXX
        **Implementation Time:** X weeks
        **Scalability Factor:** Can handle X% more volume vs human

        ### Outsourcing Option
        **Monthly Cost:** $X,XXX - Source: [platform rates]
        **Setup Time:** X weeks
        **Total First Year:** $XX,XXX
        **Quality Risk:** HIGH/MEDIUM/LOW
        **Geographic Considerations:** [location-based insights]

        ## Market Intelligence Insights
        **Salary Trends:** [Current #{@form_data['role_type']} market conditions in #{@form_data['country']}]
        **Automation Adoption:** [Industry trends and adoption rates]
        **Cost Comparison:** [Direct comparison with specific numbers]
        **ROI Timeline:** [When each option breaks even]

        ## Top Recommendation
        **Recommended Option:** [hiring/automation/outsourcing]
        **Primary Reason:** [Specific justification based on #{@form_data['budget_range']} budget and #{@form_data['timeline']} timeline]
        **Cost Advantage:** $X,XXX savings vs alternatives
        **Risk Assessment:** [Key risks and mitigation strategies]

        ## Data Sources
        [Complete list of specific URLs, documents, databases, or other sources used in the analysis. Only include public, human-readable URLs. Format each source with a title and a visible, verifiable URL. Mark each source with confidence level.]

        ## Confidence Level
        HIGH/MEDIUM/LOW - [Justification for the confidence rating based on data quality, source reliability, and comprehensiveness of market research. Explain what strengthens or weakens the confidence in these cost projections.]

        CRITICAL REQUIREMENTS:
        - Include actual dollar amounts with specific sources for every cost figure
        - State "Data not found" explicitly if information is unavailable
        - Consider #{@form_data['business_type']} industry context in all recommendations
        - Factor in #{@form_data['budget_range']} budget constraints
        - Account for #{@form_data['timeline']} urgency in hiring vs implementation timelines
        - Provide region-specific insights for #{@form_data['country']} market conditions
      FORMAT
    end
  end
end
