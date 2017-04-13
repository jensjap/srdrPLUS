require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @message_type = message_types(:one)
  end

  test 'without message_type should be invalid' do
    refute Message.new(message_type: nil).valid?
  end

  test 'with message_type should be valid' do
    assert Message.new(message_type: @message_type).valid?
  end
end
