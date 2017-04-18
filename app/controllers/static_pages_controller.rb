class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :help, :about, :search]

  def home
  end

  def help
  end

  def about
  end

  def search
  end
end
