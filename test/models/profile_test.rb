require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  def setup
    @profile_one = profiles(:one)
    @profile_two = profiles(:two)
    @user_one = users(:one)
    @user_two = users(:two)
    @organization_one = organizations(:one)
    @organization_two = organizations(:two)
  end

  test 'submitting properly formatted degree_ids should update correctly' do
    degree_ids = Degree.first(5).pluck(:id).map(&:to_s) << "<<<aaa>>>"
    params = { degree_ids: degree_ids }
    @profile_one.update(params)
    assert_equal @profile_one.degrees.count, 6
    assert_equal @profile_one.degrees.where(name: 'aaa').first, Degree.last
  end

  test 'submitting properly formatted organization_id tokens should associate profile with organization' do
    params = { organization_id: @organization_two.id.to_s }
    assert_not_nil @profile_one.organization
    @profile_one.update(params)
    assert_equal @profile_one.organization, @organization_two
  end

  test 'should properly cache Profile objects referenced directly, and also through degrees_profiles' do
    degrees_profile = profiles(:one).degrees_profiles.first
    assert_equal profiles(:one).object_id, degrees_profile.profile.object_id
  end

  test 'submitting properly formatted organization_id tokens (\'<<<0>>>\') should associate profile with newly created organization' do
    params = { organization_id: '<<<0>>>' }
    assert_equal = @profile_one.organization, @organization_one
    @profile_one.update(params)
    assert_not_equal @profile_one.organization, @organization_one
    assert_equal @profile_one.organization.name, '0'
  end

  test 'submitting properly formatted organization_id tokens should associate profile with newly created organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    previous_organization = @profile_one.organization
    assert_not_nil previous_organization
    @profile_one.update(params)
    current_organization = Organization.last
    assert_equal @profile_one.organization, current_organization
    assert_not_equal previous_organization, current_organization
  end

  test 'submitting properly formatted organization_id tokens should de-associate profile from organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    assert_not_nil @profile_one.organization
    @profile_one.update(params)
    assert_equal @profile_one.organization, Organization.last
  end

  test 'submitting malformed organization_id tokens should raise' do
    params = { organization_id: 'loyloyloy' }
    assert_not_nil @profile_one.organization
    proc { @profile_one.update(params) }.must_raise ActiveRecord::InvalidForeignKey
  end

  test 'submitting malformed organization_id tokens (0 string) should raise' do
    params = { organization_id: '0' }
    assert_not_nil @profile_one.organization
    proc { @profile_one.update(params) }.must_raise ActiveRecord::InvalidForeignKey
  end

  test 'username should not have spaces' do
    @profile_one.username = 'super cool username'
    refute @profile_one.valid?
  end

  test 'username cannot be another person\'s email' do
    @profile_one.username = @user_two.email
    refute @profile_one.valid?
    assert_equal @profile_one.errors.messages[:username], ['is invalid', 'Username already taken!']
  end

  test 'username with \'@\' symbol should be invalid' do
    @profile_one.username = 'something@something'
    refute @profile_one.valid?
    assert_equal @profile_one.errors.messages[:username], ['is invalid']
  end

  test 'profile with same user should not save' do
    @profile_one.user = @user_one
    @profile_two.user = @user_one

    @profile_one.save
    refute @profile_two.save
  end
end
