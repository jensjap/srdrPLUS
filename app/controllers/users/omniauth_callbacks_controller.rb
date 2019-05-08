class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :skip_authorization, :skip_policy_scope

  # You should configure your model like this:
  # devise :omniauthable, omniauth_providers: [:twitter]

  # You should also create an action method in this controller like this:
  # def twitter
  # end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
  def google_oauth2
    #@user = User.from_omniauth(request.env["omniauth.auth"])

    @user = current_user
    @user.update({ token: request.env["omniauth.auth"].credentials.token,
                   expires: request.env["omniauth.auth"].credentials.expires,
                   expires_at: request.env["omniauth.auth"].credentials.expires_at,
                   refresh_token: request.env["omniauth.auth"].credentials.refresh_token })

    if @user.persisted?
      #sign_in @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      session["devise.google_data"] = request.env["omniauth.auth"].except("extra")
    end

    redirect_to projects_path
  end
end
