module AiAgents
  class RoiBusinessImpact < BaseAgent
    def build_prompt
      <<~PROMPT
        <role>Senior financial analyst and business case developer with CPA background. Expert in automation ROI modeling, cost-benefit analysis, and business impact measurement. Known for conservative, realistic projections that CFOs trust.</role>

        <financial_context>
        Current Process: #{@form_data['process_description']}
        Business Scale: #{@form_data['business_type']} with #{@form_data['team_size']} team
        Budget Constraint: #{@form_data['budget_range']}
        Timeline Value: #{@form_data['timeline']}
        Role Economics: #{@form_data['role_type']} (#{@form_data['experience_level']})
        Market: #{@form_data['country']}
        </financial_context>

        <roi_methodology>
        Calculate ROI using verified market data:

        Baseline Costs: #{baseline_cost_factors}
        Opportunity Cost: #{opportunity_cost_analysis}
        Implementation Investment: #{implementation_investment_factors}
        Ongoing Operational: #{operational_cost_factors}
        </roi_methodology>

        <financial_searches>
        Target 6-8 searches for ROI validation (prioritize verified financial data):

        1. VERIFIED BASELINE COSTS:
           #{baseline_cost_searches}

        2. IMPLEMENTATION INVESTMENTS:
           #{implementation_cost_searches}

        3. OPERATIONAL SAVINGS:
           #{operational_savings_searches}

        4. ROI CASE STUDIES:
           #{roi_validation_searches}
        </financial_searches>

        <output_requirements>
        {
          "roiRankings": [
            {
              "option": "specific_financial_option",
              "score": float,
              "confidence": "HIGH/MEDIUM/LOW",
              "financialProjection": {
                "year1": {
                  "investment": "$X,XXX - Source: [verified data]",
                  "savings": "$X,XXX - Source: [case studies]",
                  "netROI": "XX% - Calculated",
                  "paybackMonths": "X months - Based on cashflow model"
                },
                "year2": {
                  "ongoingCosts": "$X,XXX - Source: [operational data]",
                  "cumulativeSavings": "$X,XXX - Projected",
                  "totalROI": "XX% - Cumulative"
                }
              },
              "businessImpact": {
                "efficiencyGains": "XX% improvement - Source: [benchmarks]",
                "qualityImprovements": "measurable quality metrics",
                "scalabilityFactor": "growth capacity multiplier",
                "riskReduction": "operational risk mitigation value"
              },
              "sensitivityAnalysis": {
                "bestCase": "optimistic scenario ROI",
                "realistic": "probable scenario ROI",
                "worstCase": "conservative scenario ROI",
                "breakEvenPoint": "minimum performance required"
              }
            }
          ],
          "opportunityCostAnalysis": {
            "delayingDecision": "cost of #{@form_data['timeline']} delay",
            "statusQuoRisk": "cost of doing nothing",
            "competitiveDisadvantage": "market positioning impact"
          },
          "reasoningChain": [/* financial reasoning steps */],
          "businessCase": {
            "executiveSummary": "CFO-ready ROI summary",
            "keyAssumptions": ["critical assumptions in financial model"],
            "riskFactors": ["financial risks and mitigations"],
            "recommendedAction": "specific next step with financial rationale"
          }
        }
        </output_requirements>

        <financial_rigor>
        - Use only verified salary and cost data with sources
        - Include all hidden costs (training, integration, maintenance)
        - Apply conservative assumptions for projections
        - Factor in #{@form_data['timeline']} urgency costs
        - Consider #{@form_data['budget_range']} budget constraints in all scenarios
        </financial_rigor>
      PROMPT
    end

    private

    def baseline_cost_factors
      if @form_data['timeline'] == 'asap'
        "Premium hiring costs, opportunity cost of delays, current inefficiency costs"
      else
        "Standard hiring costs, normal opportunity costs, current process costs"
      end
    end

    def opportunity_cost_analysis
      "Cost of #{@form_data['timeline']} delay in solving #{@form_data['process_description']} inefficiencies"
    end

    def implementation_investment_factors
      case @form_data['technical_expertise']
      when 'non-technical'
        "High vendor dependency costs, extensive training needs, ongoing support costs"
      when 'advanced'
        "Lower implementation costs, self-sufficiency benefits, faster deployment"
      else
        "Moderate implementation costs, mixed support needs"
      end
    end

    def operational_cost_factors
      "Ongoing licensing, maintenance, support, and scaling costs for #{@form_data['business_type']} context"
    end

    def baseline_cost_searches
      '"' + @form_data['role_type'] + ' total cost employment ' + @form_data['country'] + ' benefits taxes 2025"'
    end

    def implementation_cost_searches
      '"' + @form_data['process_description'] + ' automation implementation cost ' + @form_data['technical_expertise'] + ' team"'
    end

    def operational_savings_searches
      '"' + @form_data['process_description'] + ' automation ROI case study ' + @form_data['business_type'] + '"'
    end

    def roi_validation_searches
      '"site:reddit.com ' + @form_data['process_description'] + ' automation payback period real experience"'
    end
  end
end
