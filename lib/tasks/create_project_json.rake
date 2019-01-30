require 'json'

namespace :project_json do
  desc "switch rails logger to stdout"
  task :verbose => [:environment] do
    Rails.logger = Logger.new(STDOUT)
  end

  desc "Creates a json export of the given project"
  task :export_project => [:environment] do
    if ENV['pid'].nil? then raise 'No project id provided. Usage: pid=<project_id>' end
    project = Project.find( ENV['pid'] )

    project_json_content = ApplicationController.render(template: 'api/v1/projects/export.json', assigns: { project: project })

    file_folder  = Rails.root.join('public','json_exports','projects')
      #file = File.read(file_folder.join(file_name + ".json"))
      #fields = JSON.parse(form)
      #updated_fields = set_fields(fields)
    File.open(file_folder.join("project_" + ENV['pid'] + ".json"), "w") do |f|
      f.truncate 0
      f.puts project_json_content
    end
    if File.read(file_folder.join("project_" + ENV['pid'] + ".json")).length > 0
      puts "JSON successfully written: public/json_exports/projects/project_" + ENV['pid'] + ".json"
    end
  end

  desc "Reads a json export of the given project and imports it into srdrPLUS"
  task :import_project => [:environment] do
    if ENV['file'].nil? then raise 'No file provided. Usage: file=<file_path>' end
    phash = JSON.parse(File.read(Rails.root.join(ENV['file'])))['project']

    if phash.length == 0
      raise 'JSON file does not contain the key "project"'
    end
    
    # We need to check if certain parts of a project are already in database, and use info in json to check references
    # Ignore project id since we're creating a new one
    
    #if Project.find_by( id: phash['id'], name: phash['name'], description: phash['description'] ).present?
    #  raise 'Project already exists in srdrPLUS'
    #end

    p = Project.new 
    p.name = phash['name']
    p.description = phash['description']
    p.attribution = phash['attribution']
    p.methodology_description = phash['methodology_description']
    p.prospero = phash['prospero']
    p.doi = phash['doi']
    p.notes = phash['notes']
    p.funding_source = phash['funding_source']
    byebug
  end
end
