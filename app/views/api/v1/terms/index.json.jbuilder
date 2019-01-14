json.terms do
  json.array!(@terms) do |term|
    json.id term.id
    json.name term.name
  end
end
