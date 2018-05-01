require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception

  around_action :set_time_zone, if: :current_user

  before_action :set_locale
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user
  before_action :set_paper_trail_whodunnit

  def set_current_user
    User.current = current_user
  end

#  def after_sign_in_path_for(resource)
#    projects_path
#  end

  private

  def set_time_zone(&block)
    Time.use_zone(current_user.profile.time_zone, &block)
  end

  protected

    def set_locale
      I18n.locale = params[:locale] || I18n.default_locale
    end

    def configure_permitted_parameters
      added_attrs = [:username, :email, :password, :password_confirmation, :remember_me]
      devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
      devise_parameter_sanitizer.permit :account_update, keys: added_attrs
    end
end
