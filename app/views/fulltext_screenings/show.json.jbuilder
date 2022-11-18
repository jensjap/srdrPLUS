json.results @fulltext_screening_results do |fulltext_screening_result|
  json.id                       fulltext_screening_result['id']
  json.fulltext_screening_id    fulltext_screening_result['fulltext_screening_id']
  json.accession_number_alts    fulltext_screening_result['accession_number_alts']
  json.author_map_string        fulltext_screening_result['author_map_string']
  json.name                     fulltext_screening_result['name']
  json.year                     fulltext_screening_result['year']
  json.user                     fulltext_screening_result['user']
  json.user_id                  fulltext_screening_result['user_id']
  json.label                    fulltext_screening_result['label']
  json.reasons                  fulltext_screening_result['reasons']
  json.tags                     fulltext_screening_result['tags']
  json.notes                    fulltext_screening_result['notes']
  json.updated_at               fulltext_screening_result['updated_at']
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
