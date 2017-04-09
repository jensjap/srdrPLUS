require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  def setup
    @project = projects(:two)
    @publishing = publishings(:one)
    @user = users(:two)
  end

  test 'project responds to publishings' do
    assert @project.respond_to?(:publishings)
  end

  test 'publishings can created for project' do
    previous_publishings_cnt = @project.publishings.count
    @project.publishings << Publishing.create(publishable: @project, requested_by: @user)
    assert @project.publishings, previous_publishings_cnt + 1
  end
end
