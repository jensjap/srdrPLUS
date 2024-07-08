require 'test_helper'

class UserSupplyingServiceTest < ActiveSupport::TestCase
  setup do
    @service = UserSupplyingService.new
    @user = users(:one)
  end

  test "should return FHIR Practitioner" do
    user = @service.find_by_user_id(@user.id)

    assert_equal @user.id, user['id'].split('-').last.to_i
  end
end
