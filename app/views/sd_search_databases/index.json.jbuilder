json.total_count @sd_search_databases.count
json.incomplete_results false
json.items do
  json.array!(@sd_search_databases) do |sd_search_database|
    json.id sd_search_database.id
    json.name CGI.escapeHTML(sd_search_database.name)
  end
end
