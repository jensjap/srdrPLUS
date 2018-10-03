class AuthorsController < ApplicationController
  # GET /authors.json
  def index
    _page = (params[:page] || 1).to_i
    _page_size = 30
    _offset = _page_size * (_page - 1)
    _total_arr = Author.by_query(params[:q])
    @authors = _total_arr[_offset .. _offset+_page_size-1]
    @more = if @authors.length < _total_arr.length then true else false end 
  end
end


