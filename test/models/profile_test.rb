require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test 'should properly cache Profile objects referenced directly, and also through degreeholderships' do
    degreeholdership = profiles(:one).degreeholderships.first
    assert_equal profiles(:one).object_id, degreeholdership.profile.object_id
  end
end
