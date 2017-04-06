require 'test_helper'

class OrganizationProfileFlowText < Capybara::Rails::TestCase
  def setup
    sign_in(@test_superadmin)
    visit edit_profile_path
    assert page.has_content? 'Organization Information'
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

  test 'submitting properly formed organization_id tokens should associate profile with organization' do
    params = { organization_id: "#{ Organization.second.id.to_s }" }
    assert_not_nil @superadmin_profile.organization
    @superadmin_profile.update(params)
    assert_equal @superadmin_profile.organization, Organization.second
  end

  test 'submitting properly formed organization_id tokens should associate profile with newly created organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    previous_organization = @superadmin_profile.organization
    assert_not_nil previous_organization
    @superadmin_profile.update(params)
    current_organization = Organization.last
    assert_equal @superadmin_profile.organization, current_organization
    assert_not_equal previous_organization, current_organization
  end

  test 'submitting properly formed organization_id tokens should de-associate profile from organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    assert_not_nil @superadmin_profile.organization
    @superadmin_profile.update(params)
    assert_equal @superadmin_profile.organization, Organization.last
  end

  test 'submitting malformed organization_id tokens should de-associate profile from organization' do
    params = { organization_id: 'loyloyloy' }
    assert_not_nil @superadmin_profile.organization
    @superadmin_profile.update(params)
    assert_nil @superadmin_profile.organization
  end

  test 'submitting malformed organization_id tokens (0 string) should de-associate profile from organization' do
    params = { organization_id: '0' }
    assert_not_nil @superadmin_profile.organization
    @superadmin_profile.update(params)
    assert_nil @superadmin_profile.organization
  end
end
