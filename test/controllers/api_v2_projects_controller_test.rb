require 'test_helper'

class ApiV2ProjectsControllerTest < ActionDispatch::IntegrationTest
   test "can return all public projects" do
     get api_v2_public_projects_url, params: { api_key: 'TEST_API_KEY' }, as: :json
     assert_response :success
     results = JSON.parse(@response.body)
     projects = results['projects']
     # Confirm results contain projects with the expected number, names, and descriptions
     assert(projects.present?)
     assert_equal(Project.published.count, projects.length)
     assert_equal(Project.published.map(&:name).sort, projects.map { |p| p['name'] }.sort)
     assert_equal(Project.published.map(&:description).sort, projects.map { |p| p['description'] }.sort)
   end
end
