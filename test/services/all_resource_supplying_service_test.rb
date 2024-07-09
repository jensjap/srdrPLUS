require 'test_helper'

class AllResourceSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @project = projects(:one)
    @service = AllResourceSupplyingService.new
  end

  test 'should get project info in Bundle format' do
    result = @service.document_find_by_project_id(@project.id)

    assert result['entry'].present?
    assert_equal result['resourceType'], 'Bundle'
  end
end
