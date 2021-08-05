json.pagination do
  json.more @more
end

json.results do
  json.array!(@citations) do |citation|
    json.id citation.id
    json.text CGI.escapeHTML(citation.name)
  end
end

