# app/models/form_data.rb
# class FormData < ApplicationRecord
#   belongs_to :analysis

#   validates :process_description, :business_type, :role_type, presence: true

#   def to_context_hash
#     attributes.except('id', 'analysis_id', 'created_at', 'updated_at').compact
#   end
# end

# app/models/form_data.rb
class FormData < ApplicationRecord
  belongs_to :analysis

  # ================================
  # VALIDATIONS
  # ================================
  validates :company_name, presence: true
  validates :role_title, presence: true
  validates :company_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }
  validates :team_skills_level, presence: true, if: :has_internal_it_team?
  validates :team_available_hours, presence: true, if: :has_internal_it_team?

  # ================================
  # SERIALIZATIONS
  # ================================
  # Serialize array fields for multi-select inputs
  # serialize :must_have_skills, type: Array
  # serialize :preferred_compensation_model, type: Array
  # serialize :primary_pain_point, type: Array
  # serialize :existing_tools_stack, type: Array
  # serialize :key_integrations, type: Array
  # serialize :regulatory_flags, type: Array
  # serialize :security_requirements, type: Array
  # serialize :main_data_formats, type: Array
  # serialize :existing_tools_data, Array

  # ================================
  # ENUMS
  # ================================
  enum industry_business_model: {
    saas_b2b: 0,
    saas_b2c: 1,
    ecommerce: 2,
    consulting: 3,
    marketing_agency: 4,
    pr_agency: 5,
    recruitment_agency: 6,
    services_b2b: 7,
    services_b2c: 8,
    real_estate: 9,
    marketplace: 10,
    nonprofit: 11,
    industry_other: 12
  }

  enum annual_revenue_band: {
    pre_revenue: 0,
    under_500k: 1,
    k500_2m: 2,
    m2_10m: 3,
    m10_50m: 4,
    over_50m: 5
  }

  enum company_size: {
    solo: 0,
    size_2_5: 1,
    size_6_20: 2,
    size_21_50: 3,
    size_51_100: 4,
    size_100_plus: 5
  }

 enum team_skills_level: {
    team_junior: 0,
    team_mid_level: 1,
    team_senior: 2,
    team_expert: 3
  }


  enum team_available_hours: {
    under_5: 0,
    h5_15: 1,
    h15_30: 2,
    over_30: 3
  }
  enum department_function: {
    sales: 0,
    marketing: 1,
    product: 2,
    engineering: 3,
    ops: 4,
    finance: 5,
    customer_success: 6,
    hr_people: 7,
    legal_compliance: 8,
    department_other: 9
  }

  enum seniority_level: {
    junior: 0,
    mid: 1,
    senior: 2,
    expert: 3
  }

  enum employment_type: {
    full_time: 0,
    part_time: 1,
    contractor: 2,
    fractional: 3
  }

  enum location_type: {
    remote_anywhere: 0,
    remote_timezone: 1,
    hybrid: 2,
    onsite: 3
  }

  enum monthly_budget_ceiling: {
    up_to_800: 0,
    under_2k: 1,
    k2_5k: 2,
    k5_10k: 3,
    k10_20k: 4,
    over_20k: 5
  }

  enum deadline_to_fill: {
    asap: 0,
    under_1_month: 1,
    under_3_months: 2,
    under_6_months: 3,
    exploring: 4
  }

  enum tried_automating: {
    yes_worked: 0,
    yes_failed: 1,
    considering: 2,
    not_yet: 3
  }

  enum data_residency_needs: {
    us_only: 0,
    eu_only: 1,
    mixed: 2,
    no_preference: 3
  }

  # ================================
  # CALLBACKS
  # ================================
  # before_save :clean_array_fields

  # ================================
  # SCOPES
  # ================================
  # scope :by_industry, ->(industry) { where(industry_business_model: industry) }
  # scope :by_department, ->(dept) { where(department_function: dept) }
  # scope :by_budget_range, ->(budget) { where(monthly_budget_ceiling: budget) }
  # scope :recent, -> { order(created_at: :desc) }
  # scope :urgent, -> { where(deadline_to_fill: [:asap, :under_1_month]) }

  # ================================
  # HELPER METHODS
  # ================================

  # Display methods for better presentation
  def budget_display
    case monthly_budget_ceiling
    when 'up_to_800'
      'Up to $800'
    when 'under_2k'
      'Under $2K'
    when 'k2_5k'
      '$2K - $5K'
    when 'k5_10k'
      '$5K - $10K'
    when 'k10_20k'
      '$10K - $20K'
    when 'over_20k'
      'Over $20K'
    else
      monthly_budget_ceiling&.humanize
    end
  end

  def company_size_display
    case company_size
    when 'solo'
      'Solo Founder'
    when 'size_2_5'
      '2-5 employees'
    when 'size_6_20'
      '6-20 employees'
    when 'size_21_50'
      '21-50 employees'
    when 'size_51_100'
      '51-100 employees'
    when 'size_100_plus'
      '100+ employees'
    else
      company_size&.humanize
    end
  end

  def industry_display
    if industry_business_model == 'other' && industry_other.present?
      industry_other
    else
      industry_business_model&.humanize&.gsub('_', ' ')
    end
  end

  def department_display
    if department_function == 'other' && department_other.present?
      department_other
    else
      department_function&.humanize
    end
  end

  def location_display
    case location_type
    when 'onsite', 'hybrid'
      onsite_location.present? ? onsite_location : location_type&.humanize
    when 'remote_timezone'
      "Remote (#{working_hours_timezone})" if working_hours_timezone.present?
    else
      location_type&.humanize
    end
  end

  def skills_display
    must_have_skills&.join(', ')
  end

  def compensation_display
    models = preferred_compensation_model&.map(&:humanize)
    models = models + [compensation_other] if compensation_other.present?
    models&.join(', ')
  end

  # def urgency_level
  #   case deadline_to_fill
  #   when 'asap'
  #     'High'
  #   when 'under_1_month'
  #     'Medium-High'
  #   when 'under_3_months'
  #     'Medium'
  #   when 'under_6_months', 'exploring'
  #     'Low'
  #   else
  #     'Unknown'
  #   end
  # end

  # def automation_readiness_score
  #   score = 0
  #   score += 30 if has_internal_it_team && team_skills_level == 'expert'
  #   score += 25 if has_internal_it_team && team_skills_level == 'senior'
  #   score += 15 if has_internal_it_team && team_skills_level == 'mid_level'
  #   score += 10 if has_internal_it_team && team_skills_level == 'junior'

  #   score += 15 if tried_automating == 'yes_worked'
  #   score += 10 if tried_automating == 'considering'
  #   score -= 10 if tried_automating == 'yes_failed'

  #   score += 20 if existing_tools_stack.present?
  #   score += 15 if key_integrations.present?

  #   [score, 100].min
  # end

  # Updated method for new structure
  def to_context_hash
    {
      # Company info
      company: {
        name: company_name,
        url: company_url,
        industry: industry_display,
        size: company_size_display,
        revenue: budget_display,
        has_internal_it_team: has_internal_it_team? ? 'Yes' : 'No',
        team_skills_level: team_skills_level&.humanize,
        team_available_hours: team_available_hours&.humanize
      },

      # Role info
      role: {
        title: role_title,
        department: department_display,
        seniority: seniority_level&.humanize,
        employment_type: employment_type&.humanize,
        location: location_display,
        budget: budget_display,
        timeline: deadline_to_fill&.humanize,
        skills: skills_display,
        compensation: compensation_display
      },

      # Pain points
      challenges: {
        pain_points: primary_pain_point&.map(&:humanize)&.join(', '),
        current_kpi: current_kpi_baseline,
        target_improvement: target_improvement,
        desired_outcome: desired_outcome,
        manual_tasks: manual_tasks_friction
      },

      # Technical context
      tech_stack: {
        tools: existing_tools_stack&.join(', '),
        custom_tools: existing_tools_custom,
        integrations: key_integrations&.join(', '),
        automation_history: tried_automating&.humanize,
        data_formats: main_data_formats&.map(&:humanize)&.join(', ')
      },

      # Compliance
      compliance: {
        regulatory: regulatory_flags&.map(&:upcase)&.join(', '),
        data_residency: data_residency_needs&.humanize,
        security: security_requirements&.map(&:humanize)&.join(', ')
      }
    }
  end

  private

  def clean_array_fields
    self.must_have_skills = must_have_skills&.reject(&:blank?) if must_have_skills.present?
    self.preferred_compensation_model = preferred_compensation_model&.reject(&:blank?) if preferred_compensation_model.present?
    self.primary_pain_point = primary_pain_point&.reject(&:blank?) if primary_pain_point.present?
    self.existing_tools_stack = existing_tools_stack&.reject(&:blank?) if existing_tools_stack.present?
    self.key_integrations = key_integrations&.reject(&:blank?) if key_integrations.present?
    self.regulatory_flags = regulatory_flags&.reject(&:blank?) if regulatory_flags.present?
    self.security_requirements = security_requirements&.reject(&:blank?) if security_requirements.present?
    self.main_data_formats = main_data_formats&.reject(&:blank?) if main_data_formats.present?
  end
end
