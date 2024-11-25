class MessageReportJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    user_messages = {}
    messages_lookup = {}
    Message
      .includes(user: :profile)
      .where.not(help_key: nil)
      .where(created_at: 1445.minutes.ago..5.minutes.from_now)
      .each do |message|
      message.handle
      messages_lookup[message.help_key] ||= []
      messages_lookup[message.help_key] << message
    end
    recent_help_keys = Message
                       .where.not(help_key: nil)
                       .where(created_at: 1445.minutes.ago..5.minutes.from_now)
                       .select(:help_key)
                       .distinct(:help_key)
                       .pluck(:help_key)

    recent_help_keys.each do |recent_help_key|
      User
        .select(:id, :email)
        .joins(:messages, :profile)
        .where(messages: { help_key: recent_help_key })
        .each do |user|
        user_messages[user] ||= {}
        user_messages[user][recent_help_key] = messages_lookup[recent_help_key]
      end
    end

    user_messages.each do |user, messages_hash|
      MessageReportMailer.message_report(user.email, user.handle, messages_hash).deliver_later
    end
    nil
  end
end
