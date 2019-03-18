require "application_responder"

class ApplicationController < ActionController::Base
  # by default verify authorization and policy scope on all controller actions
  # use 'sp_authorization' and 'sp_policy_scope' wherever its not needed
  include Pundit
  # TODO: uncomment when controllers are set
  # after_action :verify_authorized, :verify_policy_scoped

  # rescue via custom method
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  self.responder = ApplicationResponder
  respond_to :html

  protect_from_forgery with: :exception

  around_action :set_time_zone, if: :current_user

  before_action :set_locale
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user
  before_action :set_paper_trail_whodunnit
  before_action :set_layout_style

  def authorize(*args)
    return true if Rails.env.test?
    super(*args)
  end

  def set_current_user
    User.current = current_user
  end

  def after_sign_in_path_for(resource)
    projects_path
  end

  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  private

    def user_not_authorized(exception)
      flash[:error] = 'Sorry, you are not authorized to perform this action.'
      redirect_to(request.referrer || root_path)
    end

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

    def set_layout_style
      #session[:layout_style] = Random.rand 1..2
      #cookies[:layout_style] = Random.rand 1..2 unless cookies[:layout_style]
      cookies[:layout_style] ||= Random.rand 1..1
      #cookies[:layout_style] ||= 1
    end
end
