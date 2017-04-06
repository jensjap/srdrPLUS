require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  def setup
    # We need to set this because in model tests before_action in
    # ApplicationController is not called. So if model tests run before
    # controller tests, then the User.current may not be set to the
    # correct/current user.
    User.current = User.first
  end

  test '#by_query should return correct organizations in the right order' do
    results = Organization.by_query('pirate')
    assert_equal results, Organization.where('name like ?', "%pirate%").order(:name)
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

#  test '#id_from_tokens should return a number for valid tokens (proper format)' do
#    some_number = Organization.id_from_tokens('<<<loyloyloy>>>')
#    refute_equal some_number.to_i, 0
#  end
#
#  test '#id_from_tokens should return a number for valid tokens (integer)' do
#    some_number = Organization.id_from_tokens('1')
#    refute_equal some_number, 0
#  end
#
#  test '#id_from_tokens should return nil for invalid tokens (0 integer)' do
#    some_number = Organization.id_from_tokens('0')
#    assert_nil some_number
#  end
#
#  test '#id_from_tokens should return nil for invalid tokens (improper format)' do
#    another_number = Organization.id_from_tokens('loyloyloy')
#    assert_nil another_number
#  end
end
