require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  def setup
    @profile = profiles(:one)
    @organization_one = organizations(:one)
    @organization_two = organizations(:two)
  end

  test 'submitting properly formed organization_id tokens should associate profile with organization' do
    params = { organization_id: @organization_two.id.to_s }
    assert_not_nil @profile.organization
    @profile.update(params)
    assert_equal @profile.organization, @organization_two
  end

  test 'should properly cache Profile objects referenced directly, and also through degreeholderships' do
    degreeholdership = profiles(:one).degreeholderships.first
    assert_equal profiles(:one).object_id, degreeholdership.profile.object_id
  end

  test 'submitting properly formed organization_id tokens (\'0\') should associate profile with newly created organization' do
    params = { organization_id: '<<<0>>>' }
    assert_equal = @profile.organization, @organization_one
    byebug
    @profile.update(params)
    assert_not_equal @profile.organization, @organization_one
    assert_equal @profile.organization, @organization_two
  end

  test 'submitting properly formed organization_id tokens should associate profile with newly created organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    previous_organization = @profile.organization
    assert_not_nil previous_organization
    @profile.update(params)
    current_organization = Organization.last
    assert_equal @profile.organization, current_organization
    assert_not_equal previous_organization, current_organization
  end

  test 'submitting properly formed organization_id tokens should de-associate profile from organization' do
    params = { organization_id: '<<<loyloyloy>>>' }
    assert_not_nil @profile.organization
    @profile.update(params)
    assert_equal @profile.organization, Organization.last
  end

  test 'submitting malformed organization_id tokens should raise' do
    params = { organization_id: 'loyloyloy' }
    assert_not_nil @profile.organization
    proc { @profile.update(params) }.must_raise ActiveRecord::InvalidForeignKey
  end

  test 'submitting malformed organization_id tokens (0 string) should raise' do
    params = { organization_id: '0' }
    assert_not_nil @profile.organization
    proc { @profile.update(params) }.must_raise ActiveRecord::InvalidForeignKey
  end
end
