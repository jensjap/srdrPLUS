class ImportMailer < ApplicationMailer
  default from: 'support@srdrPLUS.com'

  def notify_import_completion(current_user_id, project_id)
    @user    = User.find current_user_id
    @project = Project.find project_id
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end
end
