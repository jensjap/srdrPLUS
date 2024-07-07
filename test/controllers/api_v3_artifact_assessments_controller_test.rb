require 'test_helper'

class ArtifactAssessmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:one))
    @project = projects(:one)
  end

  test 'should get index' do
    get url_for(controller: 'api/v3/artifact_assessments', action: 'index', id: @project.id, format: :fhir_json)
    assert_response :success
  end
end
