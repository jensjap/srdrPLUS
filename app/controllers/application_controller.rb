class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_paper_trail_whodunnit
  before_action :set_current_user

  def set_current_user
    User.current = current_user
  end
end
