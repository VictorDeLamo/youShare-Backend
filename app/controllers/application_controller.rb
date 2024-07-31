class ApplicationController < ActionController::Base
  helper_method :devise_omniauthable?
  skip_before_action :verify_authenticity_token

  def devise_omniauthable?
    mapping = request.env['warden'].config[:default_scope]
    Devise.mappings[mapping].omniauthable?
  end

  def authenticate_user_api
   
    if request.headers["Accept"] == "application/json"
      api_key = request.headers["ApiKey"]
      user = User.find_by(api_key: api_key)
      if api_key.nil?
        render json: { error: "You provided no ApiKey" }, status: :unauthorized
      elsif user
        sign_in(user, bypass: true)
      else
        render json: { error: "You provided an invalid ApiKey" }, status: :forbidden
      end
    else
      authenticate_user!
    end
  end

end
