json.total_count @organizations.count
json.incomplete_results false
json.items do
  json.array!(@organizations) do |organization|
    json.extract! organization, :id, :name
    json.suggestion organization.suggestion if organization.suggestion
    json.url organization_url(organization, format: :json)
  end
end

