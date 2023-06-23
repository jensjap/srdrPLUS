json.results @abstract_screening_results do |abstract_screening_result|
  json.id                       abstract_screening_result['id']
  json.abstract_screening_id    abstract_screening_result['abstract_screening_id']
  json.accession_number_alts    abstract_screening_result['accession_number_alts']
  json.author_map_string        abstract_screening_result['author_map_string']
  json.name                     abstract_screening_result['name']
  json.year                     abstract_screening_result['year']
  json.user                     abstract_screening_result['user']
  json.user_id                  abstract_screening_result['user_id']
  json.label                    abstract_screening_result['label']
  json.privileged               abstract_screening_result['privileged']
  json.reasons                  abstract_screening_result['reasons']
  json.tags                     abstract_screening_result['tags']
  json.notes                    abstract_screening_result['notes']
  json.updated_at               abstract_screening_result['updated_at']
end
json.pagination do
  json.prev_page    @page == 1 ? 1 : @page - 1
  json.current_page @page
  json.next_page    @page >= @total_pages ? @page : @page + 1
  json.total_pages  @total_pages
  json.query        @query
  json.order_by     @order_by
  json.sort         @sort
end
