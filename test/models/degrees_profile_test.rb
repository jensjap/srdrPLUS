require 'test_helper'

class DegreesProfileTest < ActiveSupport::TestCase
  def setup
    @degrees_profile = degrees_profiles(:one)
    @degree = degrees(:one)
    @profile = profiles(:one)
  end

  test 'without degree should be invalid' do
    refute DegreesProfile.new(degree: nil, profile: @profile).valid?
  end

  test 'without profile should be invalid' do
    refute DegreesProfile.new(degree: @degree, profile: nil).valid?
  end

  test 'with degree and profile should be invalid' do
    assert DegreesProfile.new(degree: @degree, profile: @profile).valid?
  end
end
