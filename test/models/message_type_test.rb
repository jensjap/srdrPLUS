require 'test_helper'

class MessageTypeTest < ActiveSupport::TestCase
  def setup
    @frequency = frequencies(:one)
  end

  test 'without frequency should be invalid' do
    refute MessageType.new(frequency: nil).valid?
  end

  test 'with frequency should be valid' do
    assert MessageType.new(frequency: @frequency).valid?
  end
end
