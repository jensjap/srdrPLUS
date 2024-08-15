class FevirPlatformService
  API_ENDPOINT = 'https://api.fevir.net'

  def initialize(project_id, api_token)
    @project_id = project_id
    @api_token = api_token
  end

  def submit_resource
    fhir_entry = AllResourceSupplyingService.new.transaction_find_by_project_id(@project_id)
    post_data = {
      functionid: 'submitfhirresource',
      tool: 'directfhirentry',
      fhirEntry: fhir_entry,
      status: 'active',
      resourceType: 'Bundle',
      apiToken: @api_token
    }

    response = HTTParty.post(API_ENDPOINT,
                             body: post_data.to_json,
                             headers: { 'Content-Type' => 'application/json' })
    response.parsed_response
  end
end
