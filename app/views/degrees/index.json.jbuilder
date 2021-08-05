json.total_count @degrees.count
json.incomplete_results false
json.items do
  json.array!(@degrees) do |degree|
    json.id degree.id
    json.name CGI.escapeHTML(degree.name)
    if degree.suggestion
      json.suggestion do
        json.extract! degree.suggestion.user.profile, :id, :first_name
      end
    end
  end
end