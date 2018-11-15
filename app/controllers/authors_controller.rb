class AuthorsController < ApplicationController
  PAGE_SIZE = 30

  # GET /authors.json
  def index
    skip_policy_scope
    authorize(Author)

    page = (params[:page] || 1).to_i
    offset = PAGE_SIZE * (page - 1)

    @authors = Author.by_query(params[:q]).offset(offset).limit(PAGE_SIZE)
    @more = Author.by_query(params[:q]).count > offset
  end
end
