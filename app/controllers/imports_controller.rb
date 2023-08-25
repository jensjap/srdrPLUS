class ImportsController < ApplicationController
  before_action :set_project, only: %i[index new]

  def index
    authorize(@project, policy_class: ImportPolicy)
    @nav_buttons.push('import_export', 'my_projects')
    @import = @projects_user.imports.build
    @imported_file = ImportedFile.new import: @import
  end

  def new
    @import = Import.new projects_user: @projects_user
    @imported_file = ImportedFile.new import: @import
  end

  def show
    @import = Import.find(params[:id])
    @project = @import.project
    authorize(@import)
    unless current_user == @import.user
      flash[:error] = 'This import file does not belong to your user.'
      return redirect_to(project_citations_path(@project), status: 303)
    end

    @previews = @import.preview_import_job

    if @previews.blank?
      flash[:error] = 'This import cannot be previewed.'
      redirect_to(project_citations_path(@project), status: 303)
    end
    @nav_buttons.push('citation_pool', 'my_projects')
  end

  def start
    @import = Import.find(params[:id])
    @project = @import.project
    authorize(@import)
    if current_user == @import.user
      @import.start_import_job
      flash[:success] =
        'Citation file(s) successfully uploaded. You will be notified by email when the citation imports finish.'
    else
      flash[:error] = 'This import file does not belong to your user.'
    end
    redirect_to(project_citations_path(@project), status: 303)
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
    authorize(@import)

    respond_to do |format|
      if @import.save
        @import.start_import_job unless @import.import_type.name == 'Citation'
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
  extension = file.original_filename.match(/(\.[a-z]+$)/i)[0].downcase!
  ['.ris', '.csv', '.txt', '.enw', '.json'].include?(extension)
end
