namespace :project_json do
  desc "switch rails logger to stdout"
  task :verbose => [:environment] do
    Rails.logger = Logger.new(STDOUT)
  end

  desc "Creates a json export of the given project"
  task :export_project => [:environment] do
    if ENV['pid'].nil? then raise 'No project id provided. Usage: pid=<project_id>' end
    project = Project.find( ENV['pid'] )

    puts ApplicationController.render(template: 'api/v1/projects/export.json', assigns: { project: project })
  end
end
