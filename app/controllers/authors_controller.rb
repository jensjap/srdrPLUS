class AuthorsController < ApplicationController
  # GET /authors.json
  def index
    _page = (params[:page] || 1).to_i
    _page_size = 100
    _offset = _page_size * (_page - 1)
    _total_count = Author.by_query(params[:q]).length
    @authors = Author.by_query(params[:q])[_offset .. _offset+_page_size-1]
    @more = if @authors.length < _total_count then true else false end 
  end
end


