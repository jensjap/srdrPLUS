json.pagination do
  json.more @more
  json.total_count @total_count
end

json.results do
  json.array!(@citations) do |citation|
    json.citations_project_id @citation_project_dict[citation.id] if @citation_project_dict.key?(citation.id)
    json.name citation.name
    json.abstract citation.abstract_utf8
    json.pmid citation.pmid
    json.refman @citation_project_dict[citation.id].refman
    if citation.journal.present?
      json.journal do
        json.publication_date citation.journal.publication_date
        json.name citation.journal.name
        json.volume citation.journal.volume
        json.issue citation.journal.issue
      end
    end
    json.authors citation.authors
    json.keywords do
      json.array! citation.keywords, :id, :name
    end
  end
end
