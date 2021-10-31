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
  before_action :set_exit_disclaimer_message
  before_action :set_sentry_context

  def authorize(*args)
    return true if Rails.env.test?
    super(*args)
  end

  def set_current_user
    User.current = current_user
  end

  def after_sign_in_path_for(resource)
    if redirect_path.present?
      redirect_path
    else
      projects_path
    end
  end

  def after_sign_out_path_for(resource)
    new_user_session_path
  end

  private

    def redirect_path
      params.dig(:user, :redirect_path)
    end

    def user_not_authorized(exception)
      flash[:alert] = 'You are not authorized to perform this action.'
      redirect_back(fallback_location: root_path)
    end

    def set_time_zone(&block)
      Time.use_zone(current_user.profile.time_zone, &block)
    end

    def set_sentry_context
      return unless Rails.env.production?
      Sentry.set_user(id: session[:current_user_id]) # or anything else in session
      Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
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

    def set_exit_disclaimer_message
      @exit_disclaimer = "Exit Disclaimer\r\r- This external link provides additional information that is consistent with the intended purpose of a Federal site.\r- Linking to a non-Federal site does not constitute an endorsement by the Department of Health and Human Services (HHS) or any of its employees of the sponsors or the information and products presented on the site.\r- HHS cannot attest to the accuracy of information provided by this link.\r- You will be subject to the destination site's privacy policy when you follow the link."
      gon.exit_disclaimer = @exit_disclaimer
    end
end
