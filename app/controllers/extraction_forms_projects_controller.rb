class ExtractionFormsProjectsController < ApplicationController
  before_action :set_extraction_forms_project, only: [:edit]

  def edit
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extraction_forms_project
      @extraction_forms_project = ExtractionFormsProject.includes(:extraction_form).includes(:project).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_forms_project_params
      params.require(:extraction_forms_project).permit(:extraction_form_id, :project_id)
    end
end
