class Api::V1::CitationsController < Api::V1::BaseController
  def index
    _page = ( params[ :page ] || 1 ).to_i
    _query = params[ :q ] || ''
    _page_size = 200
    _offset = _page_size * (_page - 1)

    _total_arr = [ ]
    _c_p_dict = { }
    if params[ :project_id ].present?
      _p_cids = Project.find( params[ :project_id ] ).citations.map { |c| c.id }
      _total_arr = Citation.by_query( _query ).includes( :authors, :keywords, :journal ).where( id: _p_cids ).order( pmid: :desc )
      _c_p_dict = Hash[ *CitationsProject.where( citation: _total_arr ).map { |c_p| [ c_p.citation_id,  c_p.id ] }.flatten ]
    else
      _total_arr = Citation.by_query(_query)
    end

    @total_count = _total_arr.length
    @citations = _total_arr[ _offset .. _offset + _page_size - 1 ]
    @citation_project_dict = _c_p_dict
    @more = if _offset + @citations.length < _total_arr.length then true else false end
  end

  def titles
    _page = (params[ :page ] || 1).to_i
    _query = params[ :q ] || ''
    _page_size = 30
    _offset = _page_size * ( _page - 1 )
    _total_arr = Citation.by_query( _query )
    @total_count = _total_arr.length
    @citations = _total_arr[ _offset .. _offset + _page_size-1 ]
    @more = if _offset + @citations.length < _total_arr.length then true else false end
  end
end

