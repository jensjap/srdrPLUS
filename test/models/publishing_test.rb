require 'test_helper'

class PublishingTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @publishing_one = publishings(:one)
    @publishing_two = publishings(:two)  # publishings(:two) has no approval set in fixtures.
  end

  test 'requested publishing request is not approved' do
    assert @publishing_two.approval.blank?
    refute @publishing_two.approved?
  end

  test 'approving publishing request is approved' do
    refute @publishing_two.approved?
    @publishing_two.approve_by(@user)
    assert @publishing_two.approved?
  end
end
