class ExtractionFormsProjectsSectionsController < ApplicationController
  before_action :set_extraction_forms_projects_section, only: [:destroy]

  def destroy
    @extraction_forms_projects_section.destroy
    respond_to do |format|
      format.html { redirect_to edit_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project),
                    notice: 'Section was successfully removed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_extraction_forms_projects_section
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:id])
  end
end
