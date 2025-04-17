class DailyReportMailer < ApplicationMailer
  layout false

  def daily_report(email, consolidated_hash)
    @email = email
    @citation_log_messages = consolidated_hash[:screening_status_report]
    @messages_hash = consolidated_hash[:message_report]
    @extract_log_messages = consolidated_hash[:extraction_report]

    mail(to: email, subject: 'Daily report')
  end
end
