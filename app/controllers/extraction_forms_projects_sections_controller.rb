class ExtractionFormsProjectsSectionsController < ApplicationController
  before_action :set_extraction_forms_projects_section, only: [:edit, :update, :destroy]

  # GET /extraction_forms_projects_sections/1/edit
  def edit
  end

  # PATCH/PUT /extraction_forms_projects_sections/1
  # PATCH/PUT /extraction_forms_projects_sections/1.json
  def update
    respond_to do |format|
      if @extraction_forms_projects_section.update(extraction_forms_projects_section_params)
        format.html { redirect_to edit_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                                     anchor: "panel-tab-#{ @extraction_forms_projects_section.id }"),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @extraction_forms_projects_section }
      else
        format.html { render :edit }
        format.json { render json: @extraction_forms_projects_section.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @extraction_forms_projects_section.destroy
    respond_to do |format|
      format.html { redirect_to edit_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project),
                    notice: t('removed') }
      format.json { head :no_content }
    end
  end

  private

  def set_extraction_forms_projects_section
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:id])
  end

  def extraction_forms_projects_section_params
    params.require(:extraction_forms_projects_section).permit(:section_id,
                                                              questions_attributes: [:id, :_destroy, :name, :description, :question_type_id]
                                                       )
  end
end
