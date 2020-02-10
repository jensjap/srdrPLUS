class ImportMailer < ApplicationMailer
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
end
