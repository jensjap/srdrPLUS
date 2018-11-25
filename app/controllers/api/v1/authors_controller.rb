class Api::V1::AuthorsController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization

  PAGE_SIZE = 30

  # GET /authors.json
  def index
    page = (params[:page] || 1).to_i
    query = params[:q] || ''
    offset = PAGE_SIZE * (page - 1)

    @authors = Author.by_query(query).offset(offset).limit(PAGE_SIZE)
    @more = Author.by_query(query).count > offset
  end
end
