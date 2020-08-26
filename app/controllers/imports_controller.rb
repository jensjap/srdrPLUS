class ImportsController < ApplicationController
  before_action :set_project

  def new
    @import = Import.new projects_user: @projects_user
    @imported_file = ImportedFile.new import: @import
  end

  def create
    import_hash = { import_type_id: params['import_type_id'],
                    projects_user_id: params['projects_user_id'],
                    imported_files_attributes: 
                      [ { content: (params['file'] || params['content']),
                               file_type_id: params['file_type_id'] } ]
                  }
                          
    @import = Import.new(import_hash)

    respond_to do |format|
      if @import.save
        format.json { render :json => @import, status: :ok }
      else
        format.json { render :json => @import.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_project
      @project = Project.find params[:project_id]
      @projects_user = ProjectsUser.find_by project: @project, user: current_user
    end
end
