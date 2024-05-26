require 'test_helper'

class ExtractionSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @service = ExtractionSupplyingService.new
    @project = projects(:one)
    @extraction = extractions(:one)
  end

  test "should return FHIR Bundle of extractions" do
    bundle = @service.find_by_project_id(@project.id)

    assert_not_empty bundle['entry']
  end

  test "should return FHIR List of extraction" do
    fhir_list = @service.find_by_extraction_id(@extraction.id)

    assert_not_empty fhir_list['entry']
  end
end
