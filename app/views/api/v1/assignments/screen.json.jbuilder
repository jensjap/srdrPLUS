json.unlabeled_citations_projects do
  json.array!(@unlabeled_citations_projects) do |citations_project|
    citation = citations_project.citation

    json.citations_project_id citations_project.id
    json.name citation.name
    json.abstract citation.abstract
    json.pmid citation.pmid
    json.refman citation.refman
    json.journal do
      json.publication_date citation.journal.publication_date
      json.name citation.journal.name
      json.volume citation.journal.volume
      json.issue citation.journal.issue
    end
    json.authors do
      json.array! citation.authors, :id, :name
    end
    json.keywords do
      json.array! citation.keywords, :id, :name
    end
  end
end
json.labeled_citations_projects do
  json.array!(@past_labels) do |label|
    citation = label.citations_project.citation
    citations_project = label.citations_project

    json.citations_project_id citations_project.id
    json.name citation.name
    json.abstract citation.abstract
    json.pmid citation.pmid
    json.refman citation.refman
    json.journal do
      json.publication_date citation.journal.publication_date.year
      json.name citation.journal.name
      json.volume citation.journal.volume
      json.issue citation.journal.issue
    end
    json.authors do
      json.array! citation.authors, :id, :name
    end
    json.keywords do
      json.array! citation.keywords, :id, :name
    end
    json.label do
      json.id label.id
      json.value label.value
      json.user_id label.user_id
      json.created_at label.created_at
      json.updated_at label.updated_at
    end
  end
end
