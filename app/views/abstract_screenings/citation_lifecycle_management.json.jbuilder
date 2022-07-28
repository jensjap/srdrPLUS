json.citations_projects @citations_projects do |citations_project|
  json.citations_project_id citations_project.id
  json.accession_number_alts citations_project.citation.accession_number_alts
  json.author_map_string citations_project.citation.author_map_string
  json.name citations_project.citation.name
  json.year citations_project.citation.year
  json.users citations_project.abstract_screening_results.map(&:user).uniq.map(&:handle).join(', ')
  json.labels citations_project.abstract_screening_results.map(&:label).join(', ')
  json.reasons citations_project.abstract_screening_results.map(&:reasons).flatten.map(&:name).join(', ')
  json.tags citations_project.abstract_screening_results.map(&:tags).flatten.map(&:name).join(', ')
  json.note citations_project.abstract_screening_results.map(&:note).compact.map(&:value).join(', ')
  json.screening_status citations_project.screening_status
end
json.pagination do
  json.prev_page @citations_projects.prev_page
  json.current_page @citations_projects.current_page
  json.next_page @citations_projects.next_page
  json.total_pages @citations_projects.total_pages
  json.query @query
  json.order_by @order_by
  json.sort @sort
end
