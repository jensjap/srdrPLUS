json.pagination do
  json.more @more
end

json.results do
  json.array!(@keywords) do |keyword|
    json.id keyword.id
    json.text CGI.escapeHTML(keyword.name)
  end
end
