class UnreadMessageMailer < ApplicationMailer
  def bundle_notify(email, messages)
    @messages = messages
    mail(to: email, subject: 'You have new messages')
  end
end
