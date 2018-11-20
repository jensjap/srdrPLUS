json.pagination do
  json.more @more
end

json.results do
  json.array!( @tags ) do |tag|
    json.id tag.id
    json.text tag.name
  end
end

