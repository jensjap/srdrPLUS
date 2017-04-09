require 'test_helper'

class PublishingTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @publishing_approved = publishings(:one)
    @publishing_requested = publishings(:two)
  end

  test 'requested publishing request is not approved' do
    assert @publishing_requested.approved_by.blank?
    assert @publishing_requested.approved_at.blank?
    refute @publishing_requested.approved?
  end

  test 'approved publishing request is approved' do
    assert @publishing_approved.approved_by.present?
    assert @publishing_approved.approved_at.present?
    assert @publishing_approved.approved?
  end

  test 'publishing can be approved' do
    refute @publishing_requested.approved?
    @publishing_requested.approve_now(@user)
    assert @publishing_requested.approved_by.present?
    assert @publishing_requested.approved_at.present?
    assert @publishing_requested.approved?
    assert_equal @publishing_requested.approved_by, @user
  end
end
