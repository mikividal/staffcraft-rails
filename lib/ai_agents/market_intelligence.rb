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
        Analyze the context and execute ONLY the most relevant searches (6-8 maximum):

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
