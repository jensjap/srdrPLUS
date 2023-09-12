require 'test_helper'

class AllResourceSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @project = projects(:one)
    @service = AllResourceSupplyingService.new
  end

  test 'should get project info in JSON format' do
    result = @service.find_by_project_id(@project.id)
    assert result.is_a? String

    json_result = JSON.parse(result)

    assert_equal @project.name, json_result['project_name']
    assert_equal @project.description, json_result['project_description']

    assert json_result['bundle'].present?
  end
end
