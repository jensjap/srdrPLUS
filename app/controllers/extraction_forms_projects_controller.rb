class ExtractionFormsProjectsController < ApplicationController
  before_action :set_project, only: [:create]
  before_action :set_extraction_forms_project, only: [:build, :edit, :update, :destroy]

  # GET /extraction_forms_projects/1/build
  def build
  end

  # GET /extraction_forms_projects/1/edit
  def edit
  end

  # POST /projects/1/extraction_forms_projects
  # POST /projects/1/extraction_forms_projects.json
  def create
    @extraction_forms_project = @project.extraction_forms_projects.new(extraction_forms_project_params)

    respond_to do |format|
      if @extraction_forms_project.save
        format.html { redirect_to edit_project_path(@project, anchor: 'panel-extraction-form'),
                      notice: t('success') }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { redirect_to edit_project_path(@project, anchor: 'panel-extraction-form'),
                      alert: t('blank') }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extraction_forms_projects/1
  # PATCH/PUT /extraction_forms_projects/1.json
  def update
    respond_to do |format|
      if @extraction_forms_project.update(extraction_forms_project_params)
        format.html { redirect_to edit_project_path(@extraction_forms_project.project, anchor: 'panel-extraction-form'),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @extraction_forms_project }
      else
        format.html { render :edit }
        format.json { render json: @extraction_forms_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /extraction_forms_projects/1
  # DELETE /extraction_forms_projects/1.json
  def destroy
    @project = @extraction_forms_project.project
    @extraction_forms_project.destroy
    respond_to do |format|
      format.html { redirect_to edit_project_path(@project, anchor: 'panel-extraction-form'),
                    notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_extraction_forms_project
      @extraction_forms_project = ExtractionFormsProject.includes(extraction_forms_projects_sections: [:section])
                                                        .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_forms_project_params
      params.require(:extraction_forms_project).permit(extraction_form_attributes: [:name],
                                                       extraction_forms_projects_sections_attributes: [:id, :_destroy,
                                                                                                       section_attributes: [:name]])
    end
end
