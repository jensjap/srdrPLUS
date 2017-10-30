json.total_count @type1s.count
json.incomplete_results false
json.items do
  json.array!(@type1s) do |type1|
    json.extract! type1, :id, :name, :description
    if type1.suggestion
      json.suggestion do
        json.extract! type1.suggestion.user.profile, :id, :first_name
      end
    end
  end
end
