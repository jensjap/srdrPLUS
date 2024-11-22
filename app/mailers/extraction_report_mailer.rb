class ExtractionReportMailer < ApplicationMailer
  layout false

  def extraction_report(email, handle, log_messages)
    @handle = handle
    @log_messages = log_messages

    mail(to: email, subject: 'Extraction Updates')
  end
end
