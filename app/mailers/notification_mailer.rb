class NotificationMailer < ApplicationMailer
  def notify_sunset(email)
    @email = email
    mail(to: @email, subject: 'SRDRPlus Notification')
  end
end
