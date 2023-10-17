class FhirMailer < ApplicationMailer
  def send_email
    @download_url = params[:download_url]
    mail(to: params[:user_email], subject: 'You have a notification from srdrPLUS')
  end

  def send_error_email(user_email)
    mail(to: user_email, subject: 'You have a notification from srdrPLUS(export failure)')
  end
end
