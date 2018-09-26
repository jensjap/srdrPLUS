class Api::V1::CitationsController < Api::V1::BaseController
  def index
    _page = (params[:page] || 1).to_i
    _query = params[:q] || ''
    _page_size = 30
    _offset = _page_size * (_page - 1)
    _total_arr = Citation.by_query(_query)
    @total_count = _total_arr.length
    @citations = _total_arr[_offset .. _offset+_page_size-1]
    @more = if @citations.length < _total_arr.length then true else false end 
  end
end

