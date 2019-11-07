class ImportMailer < ApplicationMailer
  default from: "support@srdrPLUS.com"

  def notify_import_completion(imported_file_id)
    imported_file = ImportedFile.find imported_file_id
    @project = imported_file.project
    @filename = (imported_file.content || OpenStruct.new(:filename => "")).filename.to_s
    mail(to: imported_file.user.email, subject: "SRDR+ File Import Completed: #{@filename}")
  end

  def notify_import_failure(imported_file_id, message)
    imported_file = ImportedFile.find imported_file_id
    @project = imported_file.project
    @filename = (imported_file.content || OpenStruct.new(:filename => "")).filename.to_s
    @message = message
    mail(to: imported_file.user.email, subject: "SRDR+ File Import Failed: #{@filename}")
  end

  def notify_distiller_import_completion(project_id, user_id)
    user = User.find user_id
    @project = Project.find project_id
    mail(to: user.email, subject: "SRDR+ Project Import Completed: #{@project.name}")
  end

  def notify_distiller_import_failure(project_id, user_id)
    user = User.find user_id
    @project = Project.find project_id
    mail(to: user.email, subject: "SRDR+ Project Import Failed: #{@project.name}")
  end
end
