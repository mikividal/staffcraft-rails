class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [:login, :register]

  def login
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = JWT.encode(
        { user_id: user.id, exp: 24.hours.from_now.to_i },
        Rails.application.credentials.jwt_secret
      )

      render json: {
        token: token,
        user: UserSerializer.new(user).serialized_json
      }
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end

  def register
    user = User.new(user_params)

    if user.save
      token = JWT.encode(
        { user_id: user.id, exp: 24.hours.from_now.to_i },
        Rails.application.credentials.jwt_secret
      )

      render json: {
        token: token,
        user: UserSerializer.new(user).serialized_json
      }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def me
    render json: UserSerializer.new(current_user).serialized_json
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name, :company_name)
  end
end
