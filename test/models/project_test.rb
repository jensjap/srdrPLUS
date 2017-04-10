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

  test 'requesting publishing should create it with correct requested_by' do
    project_without_publishings = Project.where.not(id: Project.includes(:publishings).\
                                                    joins(:publishings).\
                                                    where('publishings.requested_by_id IS NOT NULL').\
                                                    pluck(:id)).first
    assert project_without_publishings.publishings.blank?
    project_without_publishings.request_publishing
    refute project_without_publishings.publishings.blank?
  end
end
