class ImportsController < ApplicationController
  before_action :set_project, only: %i[index new]

  def index
    @nav_buttons.push('import_tools')
    @import = @projects_user.imports.build
    @imported_file = ImportedFile.new import: @import
  end

  def new
    @import = Import.new projects_user: @projects_user
    @imported_file = ImportedFile.new import: @import
  end

  def create
    import_type_id = params['import_type_id'] || params['import']['import_type_id']
    if import_type_id.eql?('3')
      imported_file = params['file']
      unless _check_valid_file_type(imported_file)
        @import = Struct.new(:errors).new(nil)
        @import.errors = 'Invalid file format'
        respond_to do |format|
          format.json { render json: @import.errors.to_json, status: :unprocessable_entity }
        end
        return
      end
    end

    projects_user_id = params['projects_user_id'] || params['import']['projects_user_id']
    content = params['file'] || params['content'] || params['import']['content']
    file_type_id = params['file_type_id'] || params['import']['file_type_id']

    import_hash = {
      import_type_id:,
      projects_user_id:,
      imported_files_attributes: [
        {
          content:,
          file_type_id:
        }
      ]
    }

    @import = Import.new(import_hash)
    authorize(@import.project, policy_class: ImportPolicy)

    respond_to do |format|
      if @import.save
        format.json { render json: @import, status: :ok }
        format.html { redirect_to new_project_import_path(@import.projects_user.project), notice: t('success') }
      else
        format.json { render json: @import.errors, status: :unprocessable_entity }
        if projects_user_id.present?
          projects_user = ProjectsUser.find_by id: projects_user_id
          if projects_user.present?
            format.html { redirect_to new_project_import_path(@import.projects_user.project), alert: t('failure') }
          else
            format.html { redirect_to projects_path, alert: t('failure') }
          end
        else
          format.html { redirect_to projects_path, alert: t('failure') }
        end
      end
    end
  end

  private

  def set_project
    @project = Project.find params[:project_id]
    @projects_user = ProjectsUser.find_by project: @project, user: current_user
  end
end

def _check_valid_file_type(file)
  extension = file.original_filename.match(/(\.[a-z]+$)/i)[0]
  ['.ris', '.csv', '.txt', '.enw', '.json'].include?(extension)
end
