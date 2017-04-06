json.total_count @degrees.count
json.incomplete_results false
json.items do
  json.array!(@degrees) do |degree|
    json.extract! degree, :id, :name
    if degree.suggestion
      json.suggestion do
        json.extract! degree.suggestion.user.profile, :id, :first_name
      end
    end
  end
end
