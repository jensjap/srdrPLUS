class ExportMailer < ApplicationMailer
  default from: 'support@srdrPLUS.com'

  def notify_simple_export_completion(exported_item_id)
    @exported_item = ExportedItem.find exported_item_id
    @user    = @exported_item.projects_user.user
    @project = @exported_item.projects_user.project
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end

  def notify_simple_export_failure(user_id, project_id, message)
    @project = Project.find project_id
    @user = User.find user_id
    @message = message
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end
end
