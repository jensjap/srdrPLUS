class StaticPagesController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope, only: [:home, :help, :about, :citing, :contact, :usage, :blog]
  skip_before_action :authenticate_user!, only: [:home, :help, :about, :citing, :contact, :usage, :blog]

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc }
  }.stringify_keys

  def home
    @recently_published_projects = HTTParty.get('https://srdr.ahrq.gov/projects/api_index_published')
    case cookies[:layout_style].to_i
    when 1
      render 'home_v1'
    when 2
      render 'home_v2'
    when 3
      render 'home_v3'
    else
      render 'home'
    end
  end

  def help
  end

  def about
  end

  def citing
  end

  def contact
  end

  def usage
  end

  def blog
  end
end
