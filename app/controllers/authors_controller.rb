class AuthorsController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization

  PAGE_SIZE = 30

  # GET /authors.json
  def index
    page = (params[:page] || 1).to_i
    offset = PAGE_SIZE * (page - 1)

    @authors = Author.by_query(params[:q]).offset(offset).limit(PAGE_SIZE)
    @more = Author.by_query(params[:q]).count > offset
  end
end
