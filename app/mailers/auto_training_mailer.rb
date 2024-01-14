class AutoTrainingMailer < ApplicationMailer
  def send_error_notification(email, error_message)
    @error_message = error_message
    mail(to: email, subject: "Error Notification for ML Training")
  end
end