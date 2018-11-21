json.pagination do
  json.more @more
end

json.results do
  json.array!( @reasons ) do | reason |
    json.id reason.id
    json.text reason.name
  end
end

