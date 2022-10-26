json.results @es_hits do |es_hit|
  json.citations_project_id       es_hit['citations_project_id']
  json.citation_id                es_hit['citation_id']
  json.accession_number_alts      es_hit['accession_number_alts']
  json.author_map_string          es_hit['author_map_string']
  json.name                       es_hit['name']
  json.year                       es_hit['year']
  json.users                      es_hit['users']
  json.as_labels                  es_hit['as_labels']
  json.fs_labels                  es_hit['fs_labels']
  json.reasons                    es_hit['reasons']
  json.tags                       es_hit['tags']
  json.notes                      es_hit['notes']
  json.screening_status           es_hit['screening_status']
  json.abstract_qualification     es_hit['abstract_qualification']
  json.fulltext_qualification     es_hit['fulltext_qualification']
  json.extraction_qualification   es_hit['extraction_qualification']
  json.abstract_screening_objects es_hit['abstract_screening_objects']
  json.fulltext_screening_objects es_hit['fulltext_screening_objects']
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
