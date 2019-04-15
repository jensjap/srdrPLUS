require 'json'
require 'tasks/helpers/json_importers'

include JsonImporters

namespace :project_json do
  desc "Creates a json export of the given project"
  task export_projects: :environment do
    #projects = nil
    if ENV['pids'].present?
      pids = ENV['pids'].split(",")
      projects = Project.where(id: pids)
    else
      projects = Project.all
    end

    logger = ActiveSupport::Logger.new(Rails.root.join('tmp','json_exports','logs', 'export_projects_' + Time.now.to_i.to_s + '.log'))
    start_time = Time.now
    projects_count = projects.length

    logger.info "Task started at #{start_time}"

    projects.each.with_index do |project, index|
      puts "#{Time.now.to_s} - Processing Project ID #{project.id}"
      project_json_content = ApplicationController.render(template: 'api/v1/projects/export.json', assigns: { project: project })

      if not project_json_content.empty?
        logger.info "#{index}/#{projects_count} - project_id: #{project.id}"
      else
        logger.info "#{index}/#{projects_count} - project_id: #{project.id} - errors: #{project_json_content.errors}"
      end

      file_folder  = Rails.root.join('tmp','json_exports','projects')
      #file = File.read(file_folder.join(file_name + ".json"))
      #fields = JSON.parse(form)
      #updated_fields = set_fields(fields)
      File.open(file_folder.join("project_" + project.id.to_s + ".json"), "w+") do |f|
        f.truncate 0
        f.puts project_json_content
      end
      if File.read(file_folder.join("project_" + project.id.to_s + ".json")).length > 0
        puts "#{Time.now.to_s} - JSON successfully written: tmp/json_exports/projects/project_" + project.id.to_s + ".json"
      end
    end
    end_time = Time.now
    duration = (end_time - start_time) / 1.minute
    logger.info "Task finished at #{end_time} and last #{duration} minutes."
    logger.close
  end

  desc "Reads a json export of the given project and imports it into srdrPLUS"
  task import_projects: :environment do
    logger = ActiveSupport::Logger.new(Rails.root.join('tmp', 'json_exports', 'logs', 'import_projects_' + Time.now.to_i.to_s + '.log'))
    start_time = Time.now
    files_wildcard = Rails.root.join('tmp','json_exports', 'projects', '*.json')
    json_files = Dir.glob files_wildcard
    #projects_count = json_files.length

    logger.info "Task started at #{start_time}"

    json_files.each do |json_file|
      puts "#{Time.now.to_s} - Processing file: #{json_file}"

      begin
        fhash = JSON.parse(File.read(json_file))
      rescue
        logger.error "#{Time.now.to_s} - Cannot parse file as JSON: #{json_file}"
        next
      end

      phash = fhash["project"]

      if phash.nil?
        logger.error "#{Time.now.to_s} - JSON format not supported"
        next
      end

      project_importer = ProjectImporter.new(logger)
      project_importer.import_project(phash)

      ### create project importer
    end


    #if ENV['file'].nil? then raise 'No file provided. Usage: file=<file_path>' end

    #projects_hash.each do |pid, phash|
    # We need to check if certain parts of a project are already in database, and use info in json to check references
    # Ignore project id since we're creating a new one

    #if Project.find_by( id: phash['id'], name: phash['name'], description: phash['description'] ).present?
    #  raise 'Project already exists in srdrPLUS'
    #end

  end
end
