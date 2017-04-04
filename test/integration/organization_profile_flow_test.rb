require 'test_helper'

class OrganizationProfileFlowText < Capybara::Rails::TestCase
  def setup
    sign_in(@test_superadmin)
    visit edit_profile_path
    assert page.has_content? 'Organization Information'
  end

  test 'selecting "-- Other (new suggestion) --" should unhide New Organization Name' do
    assert page.find('#suggested-organization-fields')[:class].include? 'hide'
    within_fieldset('Organization Information') do
      select '-- Other (suggest new) --'
    end
  end

  test 'submitting all of the same fields should not create version entry' do
    versions_cnt = PaperTrail::Version.count
    click_on 'Update Profile'
    assert_equal versions_cnt, PaperTrail::Version.count
  end

  test 'selecting a different organization should create a version entry' do
    versions_cnt = PaperTrail::Version.count
    within_fieldset('Organization Information') do
      select 'Brown University'
    end
    click_on 'Update Profile'
    assert_equal versions_cnt + 1, PaperTrail::Version.count
  end
end
