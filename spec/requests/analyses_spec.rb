require 'rails_helper'

RSpec.describe "Analyses", type: :request do
  describe "POST /analyses" do
    it "crea un análisis y muestra la respuesta de Gemini" do
      analysis_params = {
        analysis: {
          form_data: {
            process_description: "Automatizar facturación",
            business_type: "SaaS",
            role_type: "Developer",
            experience_level: "Senior",
            key_skills: "Ruby, Rails",
            budget_range: "2000-5000",
            country: "España",
            team_size: "5",
            technical_expertise: "Alta",
            current_stack: "Rails, PostgreSQL",
            constraints: "Tiempo limitado",
            timeline: "Q3 2025"
          }
        }
      }

      post "/analyses", params: analysis_params
      analysis = Analysis.last
      expect(response).to redirect_to(analysis)
      follow_redirect!
      expect(response.body).to include("Analysis started!")
    end
  end
end
