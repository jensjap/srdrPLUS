require 'test_helper'

class DegreeTest < ActiveSupport::TestCase
  test 'should properly cache Degree objects referenced directly, and also through degrees_profiles' do
    degrees_profile = degrees(:one).degrees_profiles.first
    assert_equal degrees(:one).object_id, degrees_profile.degree.object_id
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
