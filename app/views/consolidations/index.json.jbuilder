json.pcg ConsolidationService.project_citations_grouping(@project)
json.consolidated_extractions @project.extractions.includes({ statusing: :status, citations_project: { citation: :journal } }).where(consolidated: true) do |extraction|
  json.id extraction.id
  json.citation_id extraction.citation.id
  json.citation_name extraction.citation.name
  json.citation_handle extraction.citation.handle
  json.status extraction.statusing.status.name
  json.status_id extraction.statusing.status.id
  json.statusing_id extraction.statusing.id
  json.approved_on extraction.approved_on
end
