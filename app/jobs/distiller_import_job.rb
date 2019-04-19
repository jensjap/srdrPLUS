require 'import_jobs/distiller_csv_import_job/_distiller_importer'
require 'import_jobs/distiller_csv_import_job/_reference_importer'
require 'import_jobs/json_import_job/_project_importer'
require 'import_jobs/_ris_citation_importer'

class DistillerImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # args:
    #   project_id,
    #   user_id,
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @user = User.find( args.first )
    @project = Project.find( args.second )

    #create importer role for user
    pu = ProjectsUser.find_or_create_by!( user: @user, project: @project )
    r_id = Role.find_by(name: 'Importer').id
    ProjectsUsersRole.find_or_create_by!( projects_user: pu, role_id: r_id )

    ris_file_type_id = FileType.find_by(name:'.ris')
    citation_import_id = ImportType.find_by(name:'Distiller References').id
    section_import_id = ImportType.find_by(name:'Distiller Section').id

    import_citations_from_ris ImportedFile.where(project: @project, user: @user, import_type_id: citation_import_id, file_type_id: ris_file_type_id).first

    project_json = JSON.parse(ApplicationController.render(template: 'api/v1/projects/export.json', assigns: { project: @project }))

    distiller_importer = DistillerImporter.new project_json, @user

    #currently we only support ris_file
    ImportedFile.where(project: @project, user: @user, import_type_id: section_import_id).each do |ifile|
      distiller_importer.add_t2_section ifile
    end

    project_importer = ProjectImporter.new(@project)
    project_importer.import_project(distiller_importer.get_imported_json["project"])

    # #we need to import references first
    # import_references @project, ImportedFile.find args.third

    # args[4..args.length].each do |s_imported_file_id|
    #   import_references @project, ImportedFile.find args.third
    # end
    # import_references @project, ImportedFile.find args.third

    ImportMailer.notify_import_completion(@user.id, @project.id).deliver_later
  end
end

