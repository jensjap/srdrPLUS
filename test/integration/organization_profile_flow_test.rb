require 'test_helper'

class OrganizationProfileFlowText < Capybara::Rails::TestCase
  def setup
    @user = users(:one)
  end

  test 'submitting all of the same fields should not create version entry' do
    sign_in_and_visit_profile_edit_page

    previous_versions_cnt = PaperTrail::Version.count
    click_on 'Update Profile'

    assert_equal PaperTrail::Version.count, previous_versions_cnt
  end

  test 'selecting a different organization should create a version entry' do
    sign_in_and_visit_profile_edit_page

    assert page.has_content? 'Organization Information'
    previous_versions_cnt = PaperTrail::Version.count
    within_fieldset('Organization Information') do
      select 'Organization Two'
    end

    click_on 'Update Profile'

    assert_equal previous_versions_cnt + 1, PaperTrail::Version.count
  end

  private

  def sign_in_and_visit_profile_edit_page
    sign_in(@user)
    visit edit_profile_path
    assert page.has_content? 'Organization Information'
  end
end
