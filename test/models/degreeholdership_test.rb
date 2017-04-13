require 'test_helper'

class DegreeholdershipTest < ActiveSupport::TestCase
  def setup
    @degreeholdership = degreeholderships(:one)
    @degree = degrees(:one)
    @profile = profiles(:one)
  end

  test 'without degree should be invalid' do
    refute Degreeholdership.new(degree: nil, profile: @profile).valid?
  end

  test 'without profile should be invalid' do
    refute Degreeholdership.new(degree: @degree, profile: nil).valid?
  end

  test 'with degree and profile should be invalid' do
    assert Degreeholdership.new(degree: @degree, profile: @profile).valid?
  end
end
