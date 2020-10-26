class StaticPagesController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope, only: [:home, :help, :about, :citing, :contact, :usage, :blog, :resources, :published_projects]
  skip_before_action :authenticate_user!, only: [:home, :help, :about, :citing, :contact, :usage, :blog, :resources, :published_projects]

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc }
  }.stringify_keys

  def home
    if current_user.present?
      redirect_to(controller: 'projects', action: 'index')
      return
    end

    begin
      url = 'https://srdr.ahrq.gov/projects/api_index_published'
      redis = Redis.new
      if cached_response = redis.get("GET:#{url}")
        unparsed_response = cached_response
      else
        unparsed_response = HTTParty.get(url).body
        redis.setex("GET:#{url}", 60 * 30, unparsed_response)
      end
      @recently_published_projects = JSON.
        parse(unparsed_response).
        sort_by { |a| -DateTime.parse(a[1]['publication_requested_at']).to_i }
    rescue
      @recently_published_projects = []
    end

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

  def published_projects
  end
end
