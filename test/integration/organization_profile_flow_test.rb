require 'test_helper'

class OrganizationProfileFlowText < Capybara::Rails::TestCase
  def setup
    sign_in(@test_superadmin)
    visit edit_profile_path
  end

  test 'selecting "-- Other (new suggestion) --" should make unhide New Organization Name' do
    assert page.has_content? 'Organization Information'

    refute_selector(:css, '#suggested-organization-fields', visible: :hidden)
    select '-- Other (suggest new) --', from: 'profile_organization_id'
    assert_selector(:css, '#suggested-organization-fields')
    select 'Brown University', from: 'profile_organization_id'
    refute_selector(:css, '#suggested-organization-fields', visible: :hidden)
  end

  test 'selecting "-- Other (new suggestion) --" but not supplying a new organization name should fail validation' do
    assert page.has_content? 'Organization Information'
  end
end
