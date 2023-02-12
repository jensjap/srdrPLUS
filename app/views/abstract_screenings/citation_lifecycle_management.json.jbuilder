json.results @citations_projects do |citations_project|
  json.citations_project_id       citations_project['citations_project_id']
  json.citation_id                citations_project['citation_id']
  json.accession_number_alts      citations_project['accession_number_alts']
  json.author_map_string          citations_project['author_map_string']
  json.name                       citations_project['name']
  json.year                       citations_project['year']
  json.users                      citations_project['users']
  json.as_labels                  citations_project['as_labels']
  json.fs_labels                  citations_project['fs_labels']
  json.reasons                    citations_project['reasons']
  json.tags                       citations_project['tags']
  json.notes                      citations_project['notes']
  json.screening_status           citations_project['screening_status']
  json.abstract_qualification     citations_project['abstract_qualification']
  json.fulltext_qualification     citations_project['fulltext_qualification']
  json.extraction_qualification   citations_project['extraction_qualification']
  json.abstract_screening_objects citations_project['abstract_screening_objects']
  json.fulltext_screening_objects citations_project['fulltext_screening_objects']
  json.abstract                   citations_project['abstract']
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
users = @project.users.sort_by { |user| user.handle.downcase }
json.users users do |user|
  json.id user.id
  json.handle user.handle
  json.selected true
end
