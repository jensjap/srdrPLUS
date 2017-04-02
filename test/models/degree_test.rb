require 'test_helper'

class DegreeTest < ActiveSupport::TestCase
  test 'should properly cache Degree objects referenced directly, and also through degreeholderships' do
    degreeholdership = degrees(:one).degreeholderships.first
    assert_equal degrees(:one).object_id, degreeholdership.degree.object_id
  end
end
