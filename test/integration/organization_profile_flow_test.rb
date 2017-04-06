require 'test_helper'

class OrganizationProfileFlowText < Capybara::Rails::TestCase
  def setup
    @user = users(:one)
    @user_profile = @user.profile
    sign_in(@user)
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
      select 'Organization Two'
    end
    click_on 'Update Profile'
    assert_equal versions_cnt + 1, PaperTrail::Version.count
  end

  test 'submitting properly formed organization_id tokens should associate profile with organization' do
    params = { organization_id: "#{ Organization.second.id.to_s }" }
    assert_not_nil @user_profile.organization
    @user_profile.update(params)
    assert_equal @user_profile.organization, Organization.second
  end

  test 'submitting properly formed organization_id tokens (\'0\') should associate profile with newly created organization' do
    params = { organization_id: '<<<0>>>' }
    previous_organization = @user_profile.organization
    assert_not_nil previous_organization
    @user_profile.update(params)
    current_organization = Organization.last
    assert_equal @user_profile.organization, current_organization
    assert_not_equal previous_organization, current_organization
  end

  test 'submitting properly formed organization_id tokens should associate profile with newly created organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    previous_organization = @user_profile.organization
    assert_not_nil previous_organization
    @user_profile.update(params)
    current_organization = Organization.last
    assert_equal @user_profile.organization, current_organization
    assert_not_equal previous_organization, current_organization
  end

  test 'submitting properly formed organization_id tokens should de-associate profile from organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    assert_not_nil @user_profile.organization
    @user_profile.update(params)
    assert_equal @user_profile.organization, Organization.last
  end

  test 'submitting malformed organization_id tokens should raise' do
    params = { organization_id: 'loyloyloy' }
    assert_not_nil @user_profile.organization
    proc { @user_profile.update(params) }.must_raise ActiveRecord::InvalidForeignKey
  end

  test 'submitting malformed organization_id tokens (0 string) should raise' do
    params = { organization_id: '0' }
    assert_not_nil @user_profile.organization
    proc { @user_profile.update(params) }.must_raise ActiveRecord::InvalidForeignKey
  end
end
