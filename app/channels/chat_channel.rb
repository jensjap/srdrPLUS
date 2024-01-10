class ChatChannel < ApplicationCable::Channel
  rescue_from 'MyError', with: :deliver_error_message

  def subscribed
    current_user.projects.each do |project|
      stream_from "chat_project-#{project.id}"
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
