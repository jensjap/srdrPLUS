require 'json_import_job/_project_importer'

class JsonImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ARGS: user_id, project_id, file_path
    #
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @user = User.find( args.first )
    @project = Project.find( args.second )
    @json_file = args.third

    begin
      fhash = JSON.parse(File.read(@json_file))
    rescue
      Rails.logger.debug "Cannot parse file as JSON: #{@json_file}"
      return
    end

    phash = fhash["project"]

    if phash.nil?
      Rails.logger.debug "Cannot find 'project' in JSON"
      return
    end

    project_importer = ProjectImporter.new(@project)
    project_importer.import_project(phash)

    ImportMailer.notify_import_completion(@user.id, @project.id).deliver_later
  end
end

