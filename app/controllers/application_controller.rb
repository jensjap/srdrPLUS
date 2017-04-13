class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  around_action :set_time_zone, if: :current_user

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user
  before_action :set_paper_trail_whodunnit

  def set_current_user
    User.current = current_user
  end

  private

  def set_time_zone(&block)
      Time.use_zone(current_user.profile.time_zone, &block)
  end

  protected

  def configure_permitted_parameters
    added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
