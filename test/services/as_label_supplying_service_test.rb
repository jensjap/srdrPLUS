require 'test_helper'

class AsLabelSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @service = AsLabelSupplyingService.new
    @project = projects(:one)
    sign_in(users(:one))
  end

  test "should return FHIR List" do
    fhir_list = @service.find_by_project_id(@project.id)

    assert_not_empty fhir_list['entry']
  end
end
