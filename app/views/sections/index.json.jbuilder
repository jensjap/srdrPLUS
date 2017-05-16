json.total_count @sections.count
json.incomplete_results false
json.items do
  json.array!(@sections) do |section|
    json.extract! section, :id, :name
    if section.suggestion
      json.suggestion do
        json.extract! section.suggestion.user.profile, :id, :first_name
      end
    end
  end
end

