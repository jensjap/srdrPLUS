require 's_import_job/import_handler'

class SImportJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second, exception.message).deliver_later
  end

  def perform(*args)
    Rails.logger.info "#{ self.class.name }: I'm performing SImportJob with arguments: #{ args.inspect }"

    user_id    = args[0]
    project_id = args[1]
    file_path  = args[2]

    ih = ImportHandler(user_id, project_id)
    ih.set_workbook(file_path)

    # Validate the workbook.
    if ih.valid_workbook
      ih.add_email_recipient('jens_jap@brown.edu')
      ih.add_email_recipient(User.find(user_id).email)

      ih.process_workbook
    end

    Rails.logger.info "#{ self.class.name }: I've finished performing SImportJob with arguments: #{ args.inspect }"
  end
end
