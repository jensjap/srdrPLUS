class StaticPagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:home, :help, :about, :search]

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc }
  }.stringify_keys

  def home
  end

  def help
  end

  def about
  end

  def search
    @query = params[:search]
    @order = params[:o] || 'updated-at'
    @results = Project.includes(publishings: [{ user: :profile }, approval: [{ user: :profile }]])
                      .by_name_description_and_query(@query).order(SORT[@order]).page(params[:page])
  end
end
