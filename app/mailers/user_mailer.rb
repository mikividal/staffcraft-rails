class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user

    track_email(:user_welcome, @user)

    mail(
      to: @user.email,
      subject: "Welcome to StaffCraft Ultra Premium!"
    )
  end

  def upgrade_confirmation(user, old_tier, new_tier)
    @user = user
    @old_tier = old_tier
    @new_tier = new_tier

    track_email(:user_upgraded, @user, { from: old_tier, to: new_tier })

    mail(
      to: @user.email,
      subject: "StaffCraft Plan Upgraded to #{new_tier.humanize}!"
    )
  end

  def daily_limit_reached(user)
    @user = user

    track_email(:daily_limit_reached, @user)

    mail(
      to: @user.email,
      subject: "StaffCraft Daily Analysis Limit Reached"
    )
  end
end
