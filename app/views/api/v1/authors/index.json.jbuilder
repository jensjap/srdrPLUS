json.pagination do
  json.more @more
end

json.results do
  json.array!(@authors) do |author|
    json.id author.id
    json.text CGI.escapeHTML(author.name)
  end
end

