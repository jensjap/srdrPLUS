json.results @es_hits do |es_hit|
  json.id                       es_hit['id']
  json.abstract_screening_id    es_hit['abstract_screening_id']
  json.accession_number_alts    es_hit['accession_number_alts']
  json.author_map_string        es_hit['author_map_string']
  json.name                     es_hit['name']
  json.year                     es_hit['year']
  json.user                     es_hit['user']
  json.user_id                  es_hit['user_id']
  json.label                    es_hit['label']
  json.reasons                  es_hit['reasons']
  json.tags                     es_hit['tags']
  json.notes                    es_hit['notes']
  json.updated_at               es_hit['updated_at']
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
