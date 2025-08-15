$NOTIFICATION_HASH = 1  # Global variable for notification hash

class NotificationJob < ApplicationJob
  include EmailHelper

  queue_as :default

  def perform(*args)
    User.in_batches(of: 50) do |batch|
      emails = batch.pluck(:email)
      cleaned_emails = emails.map { |email| clean_email(email) }
      valid_emails = cleaned_emails.select { |email| valid_email(email) }
      valid_emails.each do |email|
        next if EmailNotification.exists?(email: email, notification_hash: $NOTIFICATION_HASH, successful: true)
        NotificationMailer.notify_sunset(email).deliver_now
        user_id = User.find_by(email: email).id
        EmailNotification.create!(
          user_id: user_id,
          email: email,
          notification_hash: $NOTIFICATION_HASH,
          successful: true
        )
      end
    end
  end
end