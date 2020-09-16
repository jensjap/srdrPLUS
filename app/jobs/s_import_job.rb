require "s_import_job/import_handler"

class SImportJob < ApplicationJob
  queue_as :default

  rescue_from(StandardError) do |exception|
    # Do something with the exception
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second, exception.message).deliver_later
  end

  def perform(*args)
    Rails.logger.info "#{ self.class.name }: I'm performing SImportJob with arguments: #{ args.inspect }"

    @user = User.find_by_id(args[0].to_i)
    @import = Import.find_by_id(args[1].to_i)

    content = @import.imported_files.first.content
    file_path = process_content(content)

    ih = ImportHandler.new(@user.id, @import.project.id)
    ih.set_workbook(file_path)

    # Validate the workbook.
    if ih.valid_workbook
      ih.add_email_recipient('jens_jap@brown.edu')
      ih.add_email_recipient(@user.email)

      ih.process_workbook
    end

    Rails.logger.info "#{ self.class.name }: I've finished performing SImportJob with arguments: #{ args.inspect }"
  end
end

def process_content(content)
   # Download the content file in temp dir
   content_path = "#{ Dir.tmpdir }/#{ content.filename }"
   File.open(content_path, 'wb') do |file|
       file.write(content.download)
   end

   return content_path
end
