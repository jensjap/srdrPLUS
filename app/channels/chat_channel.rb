class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  def subscribed
    stream_from "user_#{current_user.id}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  private

  def deliver_error_message(error)
    Sentry.capture_exception(error) if Rails.env.production?
  end
end
