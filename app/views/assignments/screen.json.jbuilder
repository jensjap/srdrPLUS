json.batch_size @citations_projects.count
json.citations_projects do
  json.array!(@citations_projects) do |citations_project|
    citation = citations_project.citation
    json.id citations_project.id
    json.name citation.name
    json.abstract citation.abstract
  end
end
