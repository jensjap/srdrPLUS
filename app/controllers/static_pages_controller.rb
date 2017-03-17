class StaticPagesController < ApplicationController
  def home
      flash[:success] = 'yay'
  end

  def help
  end

  def about
  end
end
