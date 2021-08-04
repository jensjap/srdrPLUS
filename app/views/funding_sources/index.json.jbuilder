json.total_count @funding_sources.count
json.incomplete_results false
json.items do
  json.array!(@funding_sources) do |funding_source|
    json.id funding_source.id
    json.name sanitize(funding_source.name)
  end
end
