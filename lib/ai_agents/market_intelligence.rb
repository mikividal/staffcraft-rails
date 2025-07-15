module AiAgents
  class MarketIntelligence < BaseAgent
    def build_prompt
      <<~PROMPT
        <role>Expert market research analyst with 15+ years in talent acquisition, compensation analysis, and automation ROI. You have deep expertise in sourcing verified salary data, identifying reliable vendors, and conducting competitive analysis.</role>

        <context_analysis>
        Process: #{@form_data['process_description']}
        Business: #{@form_data['business_type']}
        Role: #{@form_data['role_type']} (#{@form_data['experience_level']})
        Budget: #{@form_data['budget_range']}
        Location: #{@form_data['country']}
        Team: #{@form_data['team_size']} (#{@form_data['technical_expertise']})
        Stack: #{@form_data['current_stack']}
        Timeline: #{@form_data['timeline']}
        Constraints: #{@form_data['constraints']}
        </context_analysis>

        <search_strategy>
        Analyze the context and execute ONLY the most relevant searches (3-4 maximum):

        1. SALARY INTELLIGENCE (always required):
           - Primary: "#{@form_data['role_type']} total compensation #{@form_data['country']} 2025"
          - Secondary: "#{@form_data['role_type']} salary benefits taxes cost #{@form_data['country']}"

        2. CONDITIONAL AUTOMATION COSTS:
           #{automation_search_logic}

        3. CONDITIONAL OUTSOURCING:
           #{outsourcing_search_logic}

        4. VERIFICATION SOURCES:
           #{verification_search_logic}
        </search_strategy>

        <output_requirements>
        Return structured JSON with explicit reasoning chains:

        {
          "marketRankings": [
            {
              "option": "option_name",
              "score": float,
              "confidence": "HIGH/MEDIUM/LOW",
              "monthlyCost": "$X,XXX - Source: [specific platform]",
              "dataQuality": "HIGH/MEDIUM/LOW - [reasoning]",
              "availability": "[timeline] - Source: [platform]",
              "constraints": ["specific limitations for this context"]
            }
          ],
          "reasoningChain": [
            {
              "step": 1,
              "action": "[specific action taken]",
              "source": "[exact source name]",
              "result": "[quantified finding]",
              "confidence": "HIGH/MEDIUM/LOW",
              "contextRelevance": "[why this matters for their specific case]"
            }
          ],
          "contextualInsights": {
            "urgencyFactors": "[how #{@form_data['timeline']} affects recommendations]",
            "teamConstraints": "[how #{@form_data['team_size']} #{@form_data['technical_expertise']} team affects options]",
            "budgetFit": "[options within #{@form_data['budget_range']} range]"
          },
          "dataTransparency": {
            "highConfidence": ["specific data points with strong verification"],
            "assumptions": ["explicit assumptions made"],
            "gaps": ["data not found despite searching"]
          }
        }
        </output_requirements>

        <quality_standards>
        - Every cost figure must include source attribution
        - Confidence levels must reflect actual data quality found
        - Reasoning must be specific to their context, not generic
        - Identify context-specific risks (e.g., hiring in #{@form_data['country']} market conditions)
        </quality_standards>
      PROMPT
    end

    private

    def automation_search_logic
      if @form_data['current_stack']&.downcase&.include?('salesforce')
        '- "salesforce automation #{@form_data[\'process_description\']} pricing integration"'
      elsif @form_data['current_stack']&.downcase&.include?('shopify')
        '- "shopify #{@form_data[\'process_description\']} automation apps cost"'
      elsif @form_data['business_type'] == 'SaaS B2B'
        '- "saas #{@form_data[\'process_description\']} automation tools enterprise pricing"'
      elsif @form_data['business_type'] == 'E-commerce'
        '- "ecommerce #{@form_data[\'process_description\']} automation cost comparison"'
      else
        '- "#{@form_data[\'process_description\']} automation platform pricing 2025"'
      end
    end

    def outsourcing_search_logic
      if @form_data['timeline'] == 'asap'
        '- "upwork toptal #{@form_data[\'role_type\']} immediate availability rates"'
      elsif @form_data['budget_range'] == '0-2000'
        '- "budget outsourcing #{@form_data[\'role_type\']} offshore rates quality"'
      else
        '- "premium outsourcing #{@form_data[\'role_type\']} #{@form_data[\'business_type\']} reviews"'
      end
    end

    def verification_search_logic
      if @form_data['business_type'] == 'SaaS B2B'
        '- "site:reddit.com/r/saas #{@form_data[\'role_type\']} hiring vs automation experience"'
      else
        '- "site:reddit.com #{@form_data[\'business_type\']} #{@form_data[\'process_description\']} automation vs hiring"'
      end
    end
  end
end

# module AiAgents
#   class MarketIntelligence < BaseAgent
#     def build_prompt
#       # Context-aware search strategy
#       search_strategy = determine_search_strategy

#       <<~PROMPT
#         You are an expert market research analyst with web search capabilities. Apply advanced reasoning to determine the most valuable searches for this specific case.

#         CONTEXT ANALYSIS:
#         #{form_context_summary}

#         SEARCH STRATEGY DETERMINATION:
#         #{search_strategy}

#         EXPERT SEARCH PROTOCOL:
#         Execute 6-8 HIGH-VALUE searches in this priority order:

#         PHASE 1: Core Data (Always search these 3):
#         1. "#{@form_data['role_type']} total compensation #{@form_data['country']} 2025"
#            → Get current salary + benefits data
#         2. "#{extract_key_process} automation cost comparison #{Date.current.year}"
#            → Find automation pricing for specific process
#         3. "site:reddit.com #{@form_data['business_type']} #{@form_data['role_type']} hire vs automate"
#            → Real user experiences and hidden costs

#         PHASE 2: Context-Specific (Choose 3-5 based on form data):
#         #{generate_conditional_searches}

#         PHASE 3: Validation Sources (Choose 1-2):
#         #{generate_validation_searches}

#         REASONING PROTOCOL:
#         For each cost calculation, provide explicit reasoning:

#         EXAMPLE:
#         {
#           "step": 1,
#           "action": "Retrieved base salary from multiple sources",
#           "sources": ["Glassdoor verified: $75k", "PayScale: $72k", "LinkedIn: $78k"],
#           "calculation": "Average: $75,000 ± $3,000",
#           "confidence": "HIGH - Multiple converging sources"
#         }

#         OUTPUT STRUCTURE:
#         {
#           "marketRankings": [
#             {
#               "option": "full_time_hire",
#               "score": calculated_score,
#               "confidence": "HIGH/MEDIUM/LOW with specific reason",
#               "costs": {
#                 "monthly": {
#                   "baseSalary": "$X - Source: Specific platform",
#                   "benefits": "$Y (Z% of base) - Source: BLS/local data",
#                   "taxes": "$Z - Source: Tax calculation",
#                   "overhead": "$W - Source: Industry estimate",
#                   "totalRealCost": "$TOTAL - Calculated from above"
#                 },
#                 "oneTime": {
#                   "recruiting": "$X - Source: Platform data",
#                   "onboarding": "$Y productivity loss - Source: Studies",
#                   "equipment": "$Z - Source: Market rates"
#                 },
#                 "annualRisk": {
#                   "turnover": "X% - Source: Industry data",
#                   "replacementCost": "$Y if they leave"
#                 }
#               },
#               "marketAvailability": {
#                 "candidateCount": "X active on platforms",
#                 "timeToHire": "Y weeks average",
#                 "competitionLevel": "HIGH/MEDIUM/LOW"
#               }
#             }
#           ],
#           "reasoningChain": [detailed_step_by_step_logic],
#           "searchesPerformed": [list_of_actual_searches],
#           "dataQuality": {
#             "highConfidence": [verified_data_points],
#             "estimates": [calculated_or_estimated_points],
#             "missingData": [what_couldnt_be_found],
#             "sourcesUsed": [platform_list]
#           }
#         }

#         CRITICAL SUCCESS FACTORS:
#         - Every number must have a source attribution
#         - Compare at least 3 sources for salary data
#         - Include hidden costs (benefits, taxes, overhead, risk)
#         - Validate with community discussions
#         - Flag any estimates clearly
#         - Provide confidence reasoning for each data point
#       PROMPT
#     end

#     private

#     def determine_search_strategy
#       strategy = []

#       # Budget-based strategy
#       case @form_data['budget_range']
#       when '0-2000'
#         strategy << "FOCUS: Low-cost automation solutions, offshore talent, AI tools"
#       when '20000+'
#         strategy << "FOCUS: Enterprise solutions, senior talent, comprehensive platforms"
#       else
#         strategy << "FOCUS: Mid-market solutions, balanced approach"
#       end

#       # Timeline urgency
#       if @form_data['timeline'] == 'asap'
#         strategy << "PRIORITY: Immediate solutions (outsourcing, existing tools)"
#       end

#       # Technical expertise impact
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         strategy << "CONSTRAINT: No-code solutions only, managed services preferred"
#       when 'advanced'
#         strategy << "OPPORTUNITY: Custom development, API integrations possible"
#       end

#       strategy.join("\n")
#     end

#     def extract_key_process
#       # Extract searchable terms from process description
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

#     def generate_conditional_searches
#       searches = []

#       # Current stack integration
#       if @form_data['current_stack'].present?
#         stack = @form_data['current_stack'].downcase
#         if stack.include?('salesforce')
#           searches << "4. \"Salesforce automation #{extract_key_process} integration pricing\""
#         elsif stack.include?('hubspot')
#           searches << "4. \"HubSpot workflow automation costs #{@form_data['business_type']}\""
#         else
#           searches << "4. \"#{@form_data['current_stack']} integration automation tools\""
#         end
#       end

#       # Business type specific
#       case @form_data['business_type']
#       when 'SaaS B2B'
#         searches << "5. \"B2B SaaS #{extract_key_process} automation ROI case studies\""
#       when 'E-commerce'
#         searches << "5. \"e-commerce #{extract_key_process} automation Shopify Magento\""
#       when 'Agency'
#         searches << "5. \"agency #{extract_key_process} automation client management\""
#       end

#       # Location-specific if not US
#       unless @form_data['country'].to_s.downcase.include?('united states')
#         searches << "6. \"#{@form_data['role_type']} salary #{@form_data['country']} local rates vs remote\""
#       end

#       # Team size considerations
#       case @form_data['team_size']
#       when '1'
#         searches << "7. \"solo entrepreneur #{extract_key_process} automation tools\""
#       when '50+'
#         searches << "7. \"enterprise #{extract_key_process} automation platforms comparison\""
#       end

#       searches.join("\n")
#     end

#     def generate_validation_searches
#       validations = []

#       # Community validation
#       validations << "\"site:news.ycombinator.com #{extract_key_process} automation experience\""

#       # Professional validation
#       validations << "\"#{@form_data['role_type']} market trends #{Date.current.year} McKinsey BCG\""

#       # Platform reviews
#       validations << "\"site:g2.com #{extract_key_process} automation software reviews\""

#       validations.map.with_index(8) { |search, i| "#{i}. #{search}" }.join("\n")
#     end
#   end
# end
