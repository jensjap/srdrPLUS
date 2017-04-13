require 'test_helper'

class DispatchTest < ActiveSupport::TestCase
  def setup
    @dispatch = dispatches(:one)
    @dispatchable = messages(:one)
    @user = users(:one)
  end

  test 'without dispatchable should be invalid' do
    refute Dispatch.new(dispatchable: nil, user: @user).valid?
  end

  test 'without user should be invalid' do
    refute Dispatch.new(dispatchable: nil, user: @user).valid?
  end

  test 'with dispatchable and user should be valid' do
    assert Dispatch.new(dispatchable: @dispatchable, user: @user).valid?
  end
end
