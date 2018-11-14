class Api::V1::KeywordsController < ApplicationController
  # GET /keywords.json
  def index
    _page = (params[:page] || 1).to_i
    _query = params[:q] || ''
    _page_size = 30
    _total_arr = Keyword.by_query( _query )
    _offset = [ _page_size * ( _page - 1 ), _total_arr.length ].min
    @keywords = _total_arr[ _offset .. _offset+_page_size - 1 ]
    @more = if _offset + @keywords.length < _total_arr.length then true else false end 
  end
end
