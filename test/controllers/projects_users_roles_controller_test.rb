require 'test_helper'

class ProjectsUsersRolesControllerTest < ActionDispatch::IntegrationTest
  test "should get next_assignment" do
    get projects_users_role_next_assignment_url
    assert_response :success
  end

end
