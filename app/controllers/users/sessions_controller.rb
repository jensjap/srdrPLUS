class Users::SessionsController < Devise::SessionsController
  before_action :skip_authorization, :skip_policy_scope
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    @nav_buttons.push('signin')
    super
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
