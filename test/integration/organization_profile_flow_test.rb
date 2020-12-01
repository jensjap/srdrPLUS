require 'test_helper'

class OrganizationProfileFlowText < Capybara::Rails::TestCase
  def setup
    @user = users(:one)
  end

  private

  def sign_in_and_visit_profile_edit_page
    sign_in(@user)
    visit edit_profile_path
    assert page.has_content? 'Organization Information'
  end
end
