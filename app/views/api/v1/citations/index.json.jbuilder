json.pagination do
  json.more @more
end

json.results do
  json.array!(@citations) do |citation|
    if @citation_project_dict.key?( citation.id )
      json.citations_project_id @citation_project_dict[ citation.id ]
    end
    json.name citation.name
    json.abstract citation.abstract
    json.pmid citation.pmid
    json.refman citation.refman

    if citation.journal.present?
      json.journal do
        json.publication_date citation.journal.publication_date
        json.name citation.journal.name
        json.volume citation.journal.volume
        json.issue citation.journal.issue
      end
    end

    json.authors do
      json.array! citation.authors, :id, :name
    end
    json.keywords do
      json.array! citation.keywords, :id, :name
    end
  end
end
