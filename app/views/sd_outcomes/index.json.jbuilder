json.total_count @sd_outcomes.count
json.incomplete_results false
json.items do
  json.array!(@sd_outcomes) do |sd_outcome|
    json.id sd_outcome.id
    json.name CGI.escapeHTML(sd_outcome.name)
  end
end
