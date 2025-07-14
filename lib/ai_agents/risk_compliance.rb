module AiAgents
  class RiskCompliance < BaseAgent
    def build_prompt
      <<~PROMPT
        <role>Risk management consultant and compliance expert with expertise in operational risk, regulatory requirements, and business continuity. Former Big 4 consultant with deep experience in automation risk assessment and mitigation strategies.</role>

        <risk_context>
        Business Environment: #{@form_data['business_type']} in #{@form_data['country']}
        Process Criticality: #{@form_data['process_description']}
        Team Vulnerability: #{@form_data['team_size']} #{@form_data['technical_expertise']} team
        Timeline Pressure: #{@form_data['timeline']}
        Known Constraints: #{@form_data['constraints']}
        Current Dependencies: #{@form_data['current_stack']}
        </risk_context>

        <risk_assessment_framework>
        Primary Risk Categories:
        #{primary_risk_categories}

        Business Context Risks:
        #{business_context_risks}

        Implementation Risks:
        #{implementation_specific_risks}
        </risk_assessment_framework>

        <risk_investigation>
        Execute targeted searches for risk validation (6-8 focused searches):

        1. INDUSTRY-SPECIFIC RISKS:
           #{industry_risk_searches}

        2. IMPLEMENTATION FAILURE PATTERNS:
           #{failure_pattern_searches}

        3. REGULATORY/COMPLIANCE RISKS:
           #{compliance_risk_searches}

        4. OPERATIONAL CONTINUITY RISKS:
           #{continuity_risk_searches}
        </risk_investigation>

        <output_requirements>
        {
          "riskRankings": [
            {
              "option": "specific_approach",
              "riskScore": float,
              "confidence": "HIGH/MEDIUM/LOW",
              "riskProfile": {
                "operationalRisks": [
                  {
                    "risk": "specific operational risk",
                    "probability": "HIGH/MEDIUM/LOW - Source: [data]",
                    "impact": "quantified business impact",
                    "timeline": "when this risk typically manifests",
                    "mitigation": "practical mitigation strategy",
                    "residualRisk": "remaining risk after mitigation"
                  }
                ],
                "financialRisks": [/* financial risk analysis */],
                "complianceRisks": [/* regulatory/compliance risks */],
                "technicalRisks": [/* implementation/technical risks */]
              },
              "riskMitigation": {
                "preventive": ["proactive risk prevention measures"],
                "contingency": ["backup plans if risks materialize"],
                "monitoring": ["early warning indicators"],
                "governance": ["oversight and control mechanisms"]
              },
              "businessContinuity": {
                "fallbackOptions": ["what to do if primary approach fails"],
                "rollbackPlan": "how to safely reverse implementation",
                "supportStructure": "required support for risk management"
              }
            }
          ],
          "riskMatrix": {
            "highImpactHighProb": ["critical risks requiring immediate attention"],
            "highImpactLowProb": ["low probability but severe consequence risks"],
            "lowImpactHighProb": ["nuisance risks to monitor"],
            "acceptableRisks": ["risks within tolerance levels"]
          },
          "reasoningChain": [/* risk assessment reasoning */],
          "riskRecommendations": {
            "criticalActions": ["must-do risk mitigation steps"],
            "riskTolerance": "recommended risk appetite for #{@form_data['business_type']}",
            "decisionFramework": "how to evaluate risk vs reward tradeoffs"
          }
        }
        </output_requirements>

        <risk_excellence>
        - Identify risks specific to #{@form_data['business_type']} industry context
        - Consider #{@form_data['timeline']} pressure as risk amplifier
        - Factor in #{@form_data['team_size']} team's risk management capacity
        - Address #{@form_data['constraints']} as potential risk sources
        - Provide actionable mitigation strategies, not just risk identification
        </risk_excellence>
      PROMPT
    end

    private

    def primary_risk_categories
      case @form_data['business_type']
      when 'SaaS B2B'
        "Data security, customer SLA violations, integration failures, vendor lock-in"
      when 'E-commerce'
        "Transaction processing disruption, inventory sync issues, customer experience degradation"
      when 'Agency'
        "Client delivery risks, quality control issues, resource dependency"
      else
        "Operational continuity, quality degradation, cost overruns, implementation failure"
      end
    end

    def business_context_risks
      if @form_data['timeline'] == 'asap'
        "Rush implementation increases error probability, inadequate testing, poor change management"
      elsif @form_data['team_size'] == '1'
        "Single point of failure, knowledge concentration, no backup resources"
      else
        "Standard business context risks for #{@form_data['business_type']}"
      end
    end

    def implementation_specific_risks
      case @form_data['technical_expertise']
      when 'non-technical'
        "High vendor dependency, limited troubleshooting capability, black box operations"
      when 'advanced'
        "Over-engineering risk, custom solution maintenance burden, technical debt accumulation"
      else
        "Moderate technical risks, skill gap challenges, partial dependency on vendors"
      end
    end

    def industry_risk_searches
      '"' + @form_data['business_type'] + ' ' + @form_data['process_description'] + ' automation risks regulatory compliance"'
    end

    def failure_pattern_searches
      '"site:reddit.com ' + @form_data['process_description'] + ' automation implementation failed why disaster"'
    end

    def compliance_risk_searches
      constraints = @form_data['constraints'] || ""
      if constraints.downcase.include?('compliance') || constraints.downcase.include?('security')
        '"' + @form_data['business_type'] + ' automation compliance requirements ' + @form_data['country'] + '"'
      else
        '"' + @form_data['business_type'] + ' ' + @form_data['process_description'] + ' automation regulatory risks"'
      end
    end

    def continuity_risk_searches
      '"' + @form_data['process_description'] + ' automation vendor failure backup plan business continuity"'
    end
  end
end
