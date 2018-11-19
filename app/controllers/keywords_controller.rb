class KeywordsController < ApplicationController
  PAGE_SIZE = 30

  before_action :skip_policy_scope, :skip_authorization

  # GET /keywords.json
  def index
    page = (params[:page] || 1).to_i
    offset = PAGE_SIZE * (page - 1)
    @keywords = Keyword.by_query(params[:q]).offset(offset).limit(30)
    @more = Keyword.by_query(params[:q]).count > page * PAGE_SIZE
  end
end
