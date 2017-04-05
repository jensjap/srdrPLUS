json.total_count @organizations.count
json.incomplete_results false
json.items do
  json.array!(@organizations) do |organization|
    json.extract! organization, :id, :name
    if organization.suggestion
      json.suggestion do
        json.extract! organization.suggestion.user.profile, :id, :first_name
      end
    end
    #json.url organization_url(organization, format: :json)
  end
end

