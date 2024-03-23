json.draw @draw
json.recordsTotal @project.citations_projects.length
json.recordsFiltered @citations_projects.length
json.data(@citations_projects.includes(:citation).offset(@start).limit(@length).map do |cp|
  {
    accession_number_alts: cp.citation.accession_number_alts,
    refman: cp.citation.refman,
    authors_short: cp.citation.authors_short,
    name: cp.citation.name,
    citations_project_id: cp.id,
    citation_id: cp.citation_id,
    project_id: cp.project_id,
    authors: cp.citation.authors,
  }
end)
