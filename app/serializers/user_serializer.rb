class UserSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :email, :first_name, :last_name, :company_name, :tier

  attribute :full_name do |user|
    user.full_name
  end

  attribute :analyses_remaining do |user|
    if user.enterprise?
      'unlimited'
    elsif user.premium?
      [10 - user.analyses_today, 0].max
    else
      [1 - user.analyses_today, 0].max
    end
  end
end
