require 'test_helper'

class ProjectDeletionTest < ActiveSupport::TestCase
  def setup
    # Create a simple project to test deletion
    # Use create_empty to skip default extraction form creation
    @project_to_delete = Project.new(name: 'Project To Delete')
    @project_to_delete.create_empty = true
    @project_to_delete.save!
  end

  test 'project deletion succeeds without errors' do
    assert_nothing_raised do
      @project_to_delete.destroy
    end

    assert @project_to_delete.destroyed?, 'Project should be destroyed'
  end

  test 'project deletion removes the project from database' do
    project_id = @project_to_delete.id

    assert_difference 'Project.count', -1 do
      @project_to_delete.destroy
    end

    assert_nil Project.find_by(id: project_id), 'Project should not exist in database'
  end
end
