class ExportMailer < ApplicationMailer
  def notify_screening_data_export_completion(exported_item_id)
    @exported_item = ExportedItem.find exported_item_id
    @project = @exported_item.project
    mail(to: @exported_item.user_email, subject: 'You have a notification from srdrPLUS')
  end

  def notify_screening_data_export_failure(user_email, project_id)
    @project = Project.find project_id
    @message = message
    mail(to: user_email, subject: 'You have a notification from srdrPLUS (export failure)')
  end

  def notify_simple_export_completion(exported_item_id)
    @exported_item = ExportedItem.find exported_item_id
    @project = @exported_item.project
    mail(to: @exported_item.user_email, subject: 'You have a notification from srdrPLUS')
  end

  def notify_simple_export_failure(user_email, project_id)
    @project = Project.find project_id
    @message = message
    mail(to: user_email, subject: 'You have a notification from srdrPLUS (export failure)')
  end

  def notify_gsheets_export_completion(user_id, project_id, google_link)
    @user    = User.find user_id
    @project = Project.find project_id
    @google_link = google_link
    mail(to: @user.email, subject: 'You have a notification from srdrPLUS')
  end
end
