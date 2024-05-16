require 'test_helper'

class SdMetaDataSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @service = SdMetaDataSupplyingService.new
    @project = projects(:one)
    @sd_meta_data = sd_meta_data(:one)
  end

  test "should return FHIR Bundle of sd_meta_datum" do
    bundle = @service.find_by_project_id(@project.id)

    assert_not_empty bundle['entry']
  end

  test "should return FHIR Bundle of sd_meta_data" do
    bundle = @service.find_by_sd_meta_data_id(@sd_meta_data.id)

    assert_not_empty bundle['entry']
  end
end
