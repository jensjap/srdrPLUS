json.total_count @data_analysis_levels.count
json.incomplete_results false
json.items do
  json.array!(@data_analysis_levels) do |data_analysis_level|
    json.id data_analysis_level.id
    json.name CGI.escapeHTML(data_analysis_level.name)
  end
end


