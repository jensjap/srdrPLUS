require 'test_helper'

class ProfileTest < ActiveSupport::TestCase
  test 'should properly cache Profile objects referenced directly, and also through degreeholderships' do
    degreeholdership = @superadmin_profile.degreeholderships.first
    assert_equal @superadmin_profile.object_id, degreeholdership.profile.object_id
  end
end
