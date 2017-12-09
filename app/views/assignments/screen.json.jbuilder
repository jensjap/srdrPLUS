json.batch_size @citations_projects.count
json.citations_projects do
  json.array!(@citations_projects) do |citations_project|
    citation = citations_project.citation
    json.id citations_project.id
    json.name citation.name
    json.abstract citation.abstract
    json.pmid citation.pmid
    json.refman citation.refman
    json.authors do
      json.array! citation.authors, :id, :name
    end
    json.keywords do
      json.array! citation.keywords, :id, :name
    end
  end
end
