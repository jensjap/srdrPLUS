require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  def setup
  end

  test '#by_query should return correct organizations in the right order' do
    results = Organization.by_query('orga')
    assert_equal results, Organization.where('name like ?', "%orga%").order(:name)
  end

  test '#process_token should create resource and suggestion by user' do
    previous_suggestion_cnt = Suggestion.count
    previous_organization_cnt = Organization.count
    Profile.first.send(:process_token,'<<<aaa>>>', :organization)
    assert_equal Organization.count, previous_organization_cnt + 1
    assert_equal Suggestion.count, previous_suggestion_cnt + 1
    Suggestion.last.user = User.current
  end

  test '#process_token should not create resource and suggestion by user with invalid token (\'0\')' do
    previous_suggestion_cnt = Suggestion.count
    previous_organization_cnt = Organization.count
    Profile.first.send(:process_token,'0', :organization)
    assert_equal Organization.count, previous_organization_cnt
    assert_equal Suggestion.count, previous_suggestion_cnt
  end

  test '#process_token should not create resource and suggestion by user with invalid token (\'aaa\')' do
    previous_suggestion_cnt = Suggestion.count
    previous_organization_cnt = Organization.count
    Profile.first.send(:process_token,'aaa', :organization)
    assert_equal Organization.count, previous_organization_cnt
    assert_equal Suggestion.count, previous_suggestion_cnt
  end

  test 'no new organization should be added when creating with same name' do
    previous_organization_cnt = Organization.count
    Organization.create(name: Organization.first.name)
    assert_equal Organization.count, previous_organization_cnt
  end

  test 'organization with same name should be invalid' do
    refute Organization.new(name: Organization.first.name).valid?
  end
end
