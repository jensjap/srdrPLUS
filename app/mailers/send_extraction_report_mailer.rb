class SendExtractionReportMailer < ApplicationMailer
  layout false

  def send_extraction_report(email, log_messages)
    @log_messages = log_messages

    mail(to: email, subject: 'Extraction Updates')
  end
end
