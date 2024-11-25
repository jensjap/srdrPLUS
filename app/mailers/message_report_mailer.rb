class MessageReportMailer < ApplicationMailer
  layout false

  def message_report(email, handle, messages_hash)
    @handle = handle
    @messages_hash = messages_hash

    mail(to: email, subject: 'Recent Messages')
  end
end
