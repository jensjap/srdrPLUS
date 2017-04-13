require 'test_helper'

class ApprovalTest < ActiveSupport::TestCase
  def setup
    @approval = approvals(:one)
    @approvable = publishings(:one)
    @user = users(:one)
  end

  test 'without approvable should be invalid' do
    refute Approval.new(approvable: nil, user: @user).valid?
  end

  test 'without user should be invalid' do
    refute Approval.new(approvable: @approvable, user: nil).valid?
  end

  test 'with user and approvable should be valid' do
    assert Approval.new(approvable: @approvable, user: @user).valid?
  end
end
