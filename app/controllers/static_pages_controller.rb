class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home]

  layout "static_pages"

  def home
  end

  def help
  end

  def about
  end
end
