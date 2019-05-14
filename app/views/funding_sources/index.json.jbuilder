json.total_count @funding_sources.count
json.incomplete_results false
json.items do
  json.array!(@funding_sources) do |funding_source|
    json.extract! funding_source, :id, :name
  end
end
