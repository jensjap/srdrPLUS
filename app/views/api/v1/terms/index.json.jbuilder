json.pagination do
  json.more @more
end

json.results do
  json.array!(@terms) do |term|
    json.id term.id
    json.text term.name
  end
end
