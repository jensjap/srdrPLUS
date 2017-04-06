require 'test_helper'

class DegreeTest < ActiveSupport::TestCase
  test 'should properly cache Degree objects referenced directly, and also through degreeholderships' do
    degreeholdership = degrees(:one).degreeholderships.first
    assert_equal degrees(:one).object_id, degreeholdership.degree.object_id
  end

  test 'no new degree should be added when creating with same name' do
    previous_degree_cnt = Degree.count
    Degree.create(name: Degree.first.name)
    assert_equal Degree.count, previous_degree_cnt
  end

  test 'degree with same name should be invalid' do
    refute Degree.new(name: Degree.first.name).valid?
  end
end
