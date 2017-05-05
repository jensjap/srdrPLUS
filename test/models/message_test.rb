require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  def setup
    @message_expired = messages(:one)
    @message = messages(:two)
    @message_type = message_types(:one)
  end

  test 'without message_type should be invalid' do
    refute Message.new(message_type: nil).valid?
  end

  test 'with message_type should be valid' do
    assert Message.new(message_type: @message_type).valid?
  end

  test 'expired message should return nil' do
    assert_nil @message_expired.check_message
  end

  test 'active message (no dispatches) should return' do
    # Remove all dispatches for the current user.
    User.current.dispatches.clear
    refute_nil @message.check_message
  end

  test 'active message (last dispatche is stale) should return' do
    User.current.dispatches.each { |d| d.update(created_at: 8.day.ago.to_s(:db)) }
    refute_nil @message.check_message
  end

  test 'gets tip of the day message' do
    refute_nil Message.get_totd
  end
end
