module AiAgents
  class RiskCompliance < BaseAgent
    def token_limit
      800  # From our updated limits - shortest agent
    end

    def build_prompt
      <<~PROMPT
        You are a risk management consultant specializing in automation implementation risks and regulatory compliance. You can only do web searches. *No hallucination* if any required context slot is blank, never invent.

        CONTEXT:
        CONTEXT:
        #{data_quality_instructions}
        #{handle_previous_failures}
        #{form_context}

        YOUR TASK:
        Assess risks and compliance requirements for implementing #{@form_data['process_description']} automation in your business.

        SEARCH PRIORITY:
        1. "#{@form_data['business_type']} #{@form_data['process_description']} automation risks regulatory compliance"
        2. "#{@form_data['process_description']} automation implementation failed lessons learned"
        3. "#{build_compliance_search} data protection requirements"

        #{output_format_instructions}

        SPECIFIC DATA STRUCTURE for "specific_data":
        ```json
        {
          "specific_data": {
            "overall_risk_level": "LOW/MEDIUM/HIGH",
            "top_risks": [
              {
                "risk_name": "Specific risk (e.g., Data Security Breach)",
                "probability": "LOW/MEDIUM/HIGH",
                "impact": "LOW/MEDIUM/HIGH",
                "description": "What could go wrong",
                "mitigation": "How to prevent/reduce this risk"
              }
            ],
            "compliance_requirements": {
              "data_protection": "GDPR/CCPA/other applicable laws",
              "industry_specific": "Sector-specific compliance needs",
              "security_standards": "Required security measures",
              "audit_requirements": "Record keeping and reporting needs"
            },
            "implementation_risks": {
              "technical_risk": "LOW/MEDIUM/HIGH",
              "operational_risk": "LOW/MEDIUM/HIGH",
              "vendor_dependency_risk": "LOW/MEDIUM/HIGH",
              "team_capability_risk": "LOW/MEDIUM/HIGH"
            },
            "business_continuity": {
              "backup_plan": "What to do if automation fails",
              "rollback_strategy": "How to safely reverse implementation",
              "monitoring_requirements": "What to watch for early warnings",
              "support_structure": "Required ongoing support"
            },
            "risk_mitigation_cost": {
              "additional_security": "$XXX/month",
              "compliance_tools": "$XXX setup + $XXX/month",
              "backup_processes": "$XXX/month",
              "total_risk_budget": "$X,XXX estimated"
            },
            "red_flags": [
              "Deal-breaker risks that should stop implementation",
              "Warning signs to monitor during rollout"
            ],
            "risk_vs_reward": {
              "acceptable_risk_level": "Based on business type and timeline",
              "risk_tolerance_recommendation": "Conservative/Moderate/Aggressive approach",
              "monitoring_frequency": "How often to review risks"
            }
          }
        }
        ```

        CRITICAL RISK CONSIDERATIONS:
        - Business type: #{@form_data['business_type']} has specific regulatory requirements
        - Team capability: #{@form_data['technical_expertise']} affects implementation risks
        - Timeline pressure: #{@form_data['timeline']} may increase risk levels
        - Process criticality: How important is #{@form_data['process_description']} to business operations
        - Focus on ACTIONABLE risks with specific mitigation strategies
        - Include costs of risk mitigation in analysis
      PROMPT
    end

    private

    def build_compliance_search
      case @form_data['business_type']
      when 'SaaS B2B'
        "SaaS GDPR SOC2"
      when 'E-commerce'
        "ecommerce PCI DSS customer data"
      when 'Agency'
        "agency client data confidentiality"
      else
        "#{@form_data['business_type']} automation compliance"
      end
    end
  end
end

# module AiAgents
#   class RiskCompliance < BaseAgent
#     def build_prompt
#       <<~PROMPT
#         <role>Risk management consultant and compliance expert with expertise in operational risk, regulatory requirements, and business continuity. Former Big 4 consultant with deep experience in automation risk assessment and mitigation strategies.</role>

#         <risk_context>
#         Business Environment: #{@form_data['business_type']} in #{@form_data['country']}
#         Process Criticality: #{@form_data['process_description']}
#         Team Vulnerability: #{@form_data['team_size']} #{@form_data['technical_expertise']} team
#         Timeline Pressure: #{@form_data['timeline']}
#         Known Constraints: #{@form_data['constraints']}
#         Current Dependencies: #{@form_data['current_stack']}
#         </risk_context>

#         <risk_assessment_framework>
#         Primary Risk Categories:
#         #{primary_risk_categories}

#         Business Context Risks:
#         #{business_context_risks}

#         Implementation Risks:
#         #{implementation_specific_risks}
#         </risk_assessment_framework>

#         <risk_investigation>
#         Execute targeted searches for risk validation (6-8 focused searches):

#         1. INDUSTRY-SPECIFIC RISKS:
#            #{industry_risk_searches}

#         2. IMPLEMENTATION FAILURE PATTERNS:
#            #{failure_pattern_searches}

#         3. REGULATORY/COMPLIANCE RISKS:
#            #{compliance_risk_searches}

#         4. OPERATIONAL CONTINUITY RISKS:
#            #{continuity_risk_searches}
#         </risk_investigation>

#         <output_requirements>
#           Return exactly this JSON (no comments or extra lines):
#           {
#             "analysis": "Here goes a narrative text with the 3 key risks, 3 mitigation actions, and the overall confidence level."
#         }
#         </output_requirements>

#         <risk_excellence>
#         - Identify risks specific to #{@form_data['business_type']} industry context
#         - Consider #{@form_data['timeline']} pressure as risk amplifier
#         - Factor in #{@form_data['team_size']} team's risk management capacity
#         - Address #{@form_data['constraints']} as potential risk sources
#         - Provide actionable mitigation strategies, not just risk identification
#         </risk_excellence>
#       PROMPT
#     end

#     private

#     def primary_risk_categories
#       case @form_data['business_type']
#       when 'SaaS B2B'
#         "Data security, customer SLA violations, integration failures, vendor lock-in"
#       when 'E-commerce'
#         "Transaction processing disruption, inventory sync issues, customer experience degradation"
#       when 'Agency'
#         "Client delivery risks, quality control issues, resource dependency"
#       else
#         "Operational continuity, quality degradation, cost overruns, implementation failure"
#       end
#     end

#     def business_context_risks
#       if @form_data['timeline'] == 'asap'
#         "Rush implementation increases error probability, inadequate testing, poor change management"
#       elsif @form_data['team_size'] == '1'
#         "Single point of failure, knowledge concentration, no backup resources"
#       else
#         "Standard business context risks for #{@form_data['business_type']}"
#       end
#     end

#     def implementation_specific_risks
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         "High vendor dependency, limited troubleshooting capability, black box operations"
#       when 'advanced'
#         "Over-engineering risk, custom solution maintenance burden, technical debt accumulation"
#       else
#         "Moderate technical risks, skill gap challenges, partial dependency on vendors"
#       end
#     end

#     def industry_risk_searches
#       '"' + @form_data['business_type'] + ' ' + @form_data['process_description'] + ' automation risks regulatory compliance"'
#     end

#     def failure_pattern_searches
#       '"site:reddit.com ' + @form_data['process_description'] + ' automation implementation failed why disaster"'
#     end

#     def compliance_risk_searches
#       constraints = @form_data['constraints'] || ""
#       if constraints.downcase.include?('compliance') || constraints.downcase.include?('security')
#         '"' + @form_data['business_type'] + ' automation compliance requirements ' + @form_data['country'] + '"'
#       else
#         '"' + @form_data['business_type'] + ' ' + @form_data['process_description'] + ' automation regulatory risks"'
#       end
#     end

#     def continuity_risk_searches
#       '"' + @form_data['process_description'] + ' automation vendor failure backup plan business continuity"'
#     end
#   end
# end


# module AiAgents
#   class RiskCompliance < BaseAgent
#     def build_prompt
#       risk_profile = assess_risk_profile
#       compliance_requirements = identify_compliance_needs

#       <<~PROMPT
#         You are a risk management and compliance expert specializing in technology implementation, data security, regulatory requirements, and operational risk assessment.

#         RISK ASSESSMENT CONTEXT:
#         #{form_context_summary}

#         RISK PROFILE:
#         #{risk_profile}

#         COMPLIANCE CONSIDERATIONS:
#         #{compliance_requirements}

#         EXPERT RISK SEARCH STRATEGY (6-8 focused searches):

#         PHASE 1: Implementation Risk Research (Critical for accurate assessment):
#         1. "#{identify_primary_solution} security vulnerabilities data breaches"
#         2. "#{@form_data['business_type']} #{identify_compliance_domain} compliance requirements"
#         3. "site:reddit.com #{identify_primary_solution} problems failures #{@form_data['business_type']}"

#         PHASE 2: Operational Risk Analysis:
#         #{generate_operational_risk_searches}

#         PHASE 3: Regulatory & Strategic Risk Validation:
#         #{generate_regulatory_risk_searches}

#         COMPREHENSIVE RISK FRAMEWORK:

#         1. RISK CATEGORIZATION MATRIX:
#         ```
#         Risk_Score = (Probability × Impact × Detection_Difficulty) / Mitigation_Effectiveness

#         Categories:
#         - Technical Risks: Security, reliability, performance
#         - Operational Risks: Vendor dependency, skill gaps, process disruption
#         - Financial Risks: Cost overruns, ROI failure, switching costs
#         - Strategic Risks: Competitive disadvantage, compliance violations
#         - Reputational Risks: Customer impact, data breaches, service failures
#         ```

#         2. RISK VALIDATION METHODOLOGY:
#         - Search for real incident reports and user experiences
#         - Cross-reference vendor claims with independent assessments
#         - Identify industry-specific risk patterns
#         - Evaluate risk trajectory (improving vs worsening)

#         3. MITIGATION STRATEGY ASSESSMENT:
#         - Evaluate effectiveness of available risk controls
#         - Assess cost/complexity of risk mitigation
#         - Determine acceptable residual risk levels

#         REQUIRED OUTPUT STRUCTURE:
#         {
#           "riskRankings": [
#             {
#               "option": "ai_automation_platform",
#               "riskScore": calculated_composite_score,
#               "confidence": "HIGH - Based on X incident reports + Y user experiences",
#               "riskProfile": {
#                 "overall": "MEDIUM-HIGH risk with significant mitigation opportunities",
#                 "primaryConcerns": ["AI hallucination in customer communications", "Vendor lock-in"],
#                 "riskTrend": "IMPROVING - Platform security/reliability advancing"
#               },
#               "riskCategories": {
#                 "technical": {
#                   "score": "7/10 - Significant complexity",
#                   "topRisks": [
#                     {
#                       "risk": "AI model hallucinations affecting customer interactions",
#                       "probability": "15% - Based on user reports",
#                       "impact": "HIGH - Customer trust damage, potential legal issues",
#                       "detection": "MEDIUM - May not be immediately obvious",
#                       "evidence": "Site:reddit.com shows Y% users experienced this",
#                       "mitigation": {
#                         "strategies": ["Human oversight loops", "Confidence thresholds", "Escalation triggers"],
#                         "effectiveness": "80% risk reduction when properly implemented",
#                         "cost": "$X/month additional human review time"
#                       }
#                     }
#                   ]
#                 },
#                 "operational": {
#                   "score": "6/10 - Manageable with preparation",
#                   "topRisks": [
#                     {
#                       "risk": "Team lacks skills to troubleshoot AI system issues",
#                       "probability": "40% for #{@form_data['technical_expertise']} teams",
#                       "impact": "MEDIUM - Service degradation during issues",
#                       "mitigation": {
#                         "strategies": ["Vendor support SLA", "Technical training", "Backup processes"],
#                         "effectiveness": "90% with comprehensive support plan"
#                       }
#                     }
#                   ]
#                 },
#                 "financial": {
#                   "score": "5/10 - Moderate cost control challenges",
#                   "considerations": ["API usage cost unpredictability", "Integration complexity budget overruns"]
#                 },
#                 "compliance": {
#                   "score": calculated_based_on_industry,
#                   "requirements": identified_compliance_needs,
#                   "gaps": ["Data residency unclear", "Audit trail limitations"],
#                   "mitigationCost": "$X for compliance tooling"
#                 },
#                 "strategic": {
#                   "score": "4/10 - Long-term advantages outweigh risks",
#                   "considerations": ["Competitive necessity", "Learning curve advantages"]
#                 }
#               },
#               "industrySpecificRisks": {
#                 "#{@form_data['business_type']}": [
#                   "Specific risks found in research for this business type"
#                 ]
#               },
#               "riskComparison": {
#                 "vsHiring": "60% lower risk than hiring challenges",
#                 "vsStatusQuo": "Higher short-term risk, lower long-term risk",
#                 "riskTradeoffs": "Trading people risks for technology risks"
#               },
#               "mitigationPlan": {
#                 "phase1": {
#                   "actions": ["Pilot with low-risk use case", "Establish monitoring"],
#                   "cost": "$X",
#                   "timeline": "Week 1-2"
#                 },
#                 "phase2": {
#                   "actions": ["Full deployment with safeguards", "Team training"],
#                   "cost": "$Y",
#                   "timeline": "Month 1-2"
#                 },
#                 "ongoing": {
#                   "monitoring": ["Performance metrics", "Error rate tracking"],
#                   "cost": "$Z/month",
#                   "reviewCycle": "Monthly risk assessment"
#                 }
#               }
#             }
#           ],
#           "reasoningChain": [
#             {
#               "step": 1,
#               "action": "Researched real-world incidents and failure modes",
#               "sources": ["Security databases", "User forums", "Incident reports"],
#               "findings": "X incidents found, Y patterns identified",
#               "confidence": "HIGH - Multiple independent sources"
#             },
#             {
#               "step": 2,
#               "action": "Evaluated risk probability based on implementation context",
#               "methodology": "Weighted team capabilities + industry patterns + solution maturity",
#               "result": "Risk probability adjusted for #{@form_data['technical_expertise']} team context",
#               "confidence": "MEDIUM - Context-specific adjustment"
#             }
#           ],
#           "riskRecommendations": {
#             "riskTolerance": "Based on #{@form_data['business_type']} and #{@form_data['timeline']} urgency",
#             "recommendedApproach": "Graduated risk approach with monitoring gates",
#             "dealBreakers": ["Risks that should prevent implementation"],
#             "mandatoryMitigations": ["Non-negotiable risk controls"],
#             "riskBudget": "Reserve X% of implementation budget for risk mitigation"
#           }
#         }

#         CRITICAL RISK VALIDATION REQUIREMENTS:
#         - Research actual incidents, not just theoretical risks
#         - Validate risk probabilities with real user data
#         - Assess risk severity in context of business impact
#         - Evaluate mitigation strategy effectiveness with evidence
#         - Consider risk evolution over time (improving vs degrading)
#         - Factor in team's risk management capabilities
#         - Provide actionable risk controls, not just risk identification
#         - Account for risk interdependencies and cascading effects
#       PROMPT
#     end

#     private

#     def assess_risk_profile
#       profile = []

#       # Technical risk factors
#       case @form_data['technical_expertise']
#       when 'non-technical'
#         profile << "HIGH TECH RISK: Limited internal troubleshooting capability"
#         profile << "DEPENDENCY RISK: Heavy reliance on vendor support"
#       when 'advanced'
#         profile << "LOW TECH RISK: Strong internal technical capabilities"
#         profile << "OPPORTUNITY: Can implement additional risk controls"
#       end

#       # Business context risks
#       case @form_data['business_type']
#       when 'SaaS B2B'
#         profile << "CUSTOMER RISK: Service disruptions affect client relationships"
#       when 'E-commerce'
#         profile << "REVENUE RISK: Automation failures directly impact sales"
#       end

#       # Urgency vs risk tradeoffs
#       if @form_data['timeline'] == 'asap'
#         profile << "IMPLEMENTATION RISK: Rushed deployment increases failure probability"
#       end

#       profile.join("\n")
#     end

#     def identify_compliance_needs
#       needs = []

#       # Industry-specific compliance
#       case @form_data['business_type']
#       when 'SaaS B2B'
#         needs << "DATA PROTECTION: GDPR, SOC2, customer data handling"
#       when 'E-commerce'
#         needs << "FINANCIAL: PCI DSS, payment processing, customer data"
#       when 'Agency'
#         needs << "CLIENT DATA: Confidentiality, data residency, audit trails"
#       end

#       # Process-specific compliance
#       if @form_data['process_description'].to_s.downcase.include?('customer')
#         needs << "CUSTOMER COMMUNICATION: Record keeping, quality standards"
#       end

#       # Location-specific compliance
#       unless @form_data['country'].to_s.downcase.include?('united states')
#         needs << "INTERNATIONAL: Local data protection laws, cross-border data transfer"
#       end

#       needs.join("\n")
#     end

#     def identify_primary_solution
#       # Determine most likely solution to focus risk research
#       if @form_data['technical_expertise'] == 'non-technical'
#         'no-code automation platform'
#       elsif @form_data['process_description'].to_s.downcase.include?('customer support')
#         'AI customer service platform'
#       else
#         'business automation platform'
#       end
#     end

#     def identify_compliance_domain
#       if @form_data['process_description'].to_s.downcase.include?('customer')
#         'customer data'
#       elsif @form_data['process_description'].to_s.downcase.include?('financial')
#         'financial data'
#       else
#         'business data'
#       end
#     end

#     def generate_operational_risk_searches
#       searches = []

#       # Vendor dependency research
#       searches << "4. \"#{identify_primary_solution} vendor lock-in risks alternatives\""

#       # Team capability gaps
#       searches << "5. \"#{@form_data['technical_expertise']} team manage #{identify_primary_solution} challenges\""

#       # Business continuity
#       searches << "6. \"#{identify_primary_solution} outage impact #{@form_data['business_type']}\""

#       searches.join("\n")
#     end

#     def generate_regulatory_risk_searches
#       searches = []

#       # Compliance validation
#       searches << "\"#{@form_data['business_type']} automation compliance requirements #{@form_data['country']}\""

#       # Security research
#       searches << "\"#{identify_primary_solution} security audit findings vulnerabilities\""

#       searches.map.with_index(7) { |search, i| "#{i}. #{search}" }.join("\n")
#     end
#   end
# end
