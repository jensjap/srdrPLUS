json.total_count @sd_search_databases.count
json.incomplete_results false
json.items do
  json.array!(@sd_search_databases) do |sd_search_database|
    json.extract! sd_search_database, :id, :name
  end
end
