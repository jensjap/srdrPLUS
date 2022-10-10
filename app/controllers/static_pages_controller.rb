class StaticPagesController < ApplicationController
  before_action :skip_authorization, :skip_policy_scope,
                only: %i[home help about citing contact usage blog resources published_projects]
  skip_before_action :authenticate_user!,
                     only: %i[home help about citing contact usage blog resources published_projects]

  SORT = {  'updated-at': { updated_at: :desc },
            'created-at': { created_at: :desc } }.stringify_keys

  def home
    @nav_buttons.push('home')
    begin
      url = 'https://srdr.ahrq.gov/projects/api_index_published'
      redis = Redis.new
      if cached_response = redis.get("GET:#{url}")
        unparsed_response = cached_response
      else
        unparsed_response = HTTParty.get(url).body
        redis.setex("GET:#{url}", 60 * 30, unparsed_response)
      end
      @recently_published_projects = JSON
                                     .parse(unparsed_response)
                                     .sort_by { |a| -DateTime.parse(a[1]['publication_requested_at']).to_i }
    rescue StandardError
      @recently_published_projects = []
    end

    return redirect_to(projects_path) if current_user && !params[:no_redirect]
  end

  def help
    @nav_buttons.push('help')
  end

  def about
    @nav_buttons.push('about')
  end

  def citing
    @nav_buttons.push('citing')
  end

  def contact
    @nav_buttons.push('contact')
  end

  def usage
    @nav_buttons.push('usage')
  end

  def blog
    @nav_buttons.push('blog')
  end

  def published_projects
    @nav_buttons.push('published_projects')
    @projects = Project.joins([publishing: :approval]).order('approvals.created_at DESC').page(params[:page]).per(5)
  end
end
