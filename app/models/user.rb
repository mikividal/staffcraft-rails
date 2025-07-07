class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :analyses, dependent: :destroy

  enum tier: { free: 0, premium: 1, enterprise: 2 }

  validates :first_name, :last_name, presence: true
  validates :tier, presence: true # MV added this

  def full_name
    "#{first_name} #{last_name}"
  end

  def can_create_analysis?
    return true if enterprise?
    return analyses_today < 10 if premium?
    analyses_today < 1 # free tier
  end

  def analyses_today
    return 0 unless last_analysis_date == Date.current
    daily_analysis_count
  end

  def increment_daily_analysis!
    if last_analysis_date != Date.current
      update!(last_analysis_date: Date.current, daily_analysis_count: 1)
    else
      increment!(:daily_analysis_count)
    end
  end
end
