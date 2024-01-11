class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  def subscribed
    ChatChannelService.generate_rooms(current_user).each do |_, rooms|
      rooms.each do |room|
        stream_from "chat_#{room}"
      end
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(error)
    Sentry.capture_exception(error) if Rails.env.production?
  end
end
