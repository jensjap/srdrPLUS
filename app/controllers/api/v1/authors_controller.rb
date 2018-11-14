class Api::V1::AuthorsController < ApplicationController
  # GET /authors.json
  def index
    _page = (params[:page] || 1).to_i
    _query = params[:q] || ''
    _page_size = 30
    _total_arr = Author.by_query( _query )
    _offset = [ _page_size * ( _page - 1 ), _total_arr.length ].min
    @authors = _total_arr[ _offset .. _offset+_page_size - 1 ]
    @more = if _offset + @authors.length < _total_arr.length then true else false end 
  end
end


