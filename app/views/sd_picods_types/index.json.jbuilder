json.total_count @sd_picods_types.count
json.incomplete_results false
json.items do
  json.array!(@sd_picods_types) do |sd_picods_type|
    json.id sd_picods_type.id
    json.name CGI.escapeHTML(sd_picods_type.name)
  end
end
