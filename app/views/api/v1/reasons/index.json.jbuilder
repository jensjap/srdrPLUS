json.pagination do
  json.more @more
end

json.results do
  json.array!( @reasons ) do | reason |
    json.id reason.id
    json.text CGI.escapeHTML(reason.name)
  end
end

