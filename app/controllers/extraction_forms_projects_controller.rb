class ExtractionFormsProjectsController < ApplicationController
  before_action :set_extraction_forms_project, only: [:edit, :update]

  def edit
  end

  # PATCH/PUT /extraction_forms_projects/1
  # PATCH/PUT /extraction_forms_projects/1.json
  def update
    respond_to do |format|
      if @extraction_forms_project.update(extraction_forms_project_params)
        format.html { redirect_to edit_extraction_forms_project_path(@extraction_forms_project), notice: 'Project was successfully updated.' }
        format.json { render :show, status: :ok, location: @extraction_forms_project }
      else
        format.html { render :edit }
        format.json { render json: @extraction_forms_project.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extraction_forms_project
      @extraction_forms_project = ExtractionFormsProject.includes(extraction_forms_projects_sections: [:section])
                                                        .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_forms_project_params
      params.require(:extraction_forms_project).permit(extraction_forms_projects_sections_attributes: [:id, :_destroy,
                                                                                                       section_attributes: [:name]])
    end
end
