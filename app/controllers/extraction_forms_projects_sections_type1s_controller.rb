class ExtractionFormsProjectsSectionsType1sController < ApplicationController
  before_action :set_extraction_forms_projects_sections_type1, only: %i[edit update]

  def edit; end

  def update
    respond_to do |format|
      if @extraction_forms_projects_sections_type1.update(extraction_forms_projects_sections_type1_params)
        format.html do
          redirect_to build_extraction_forms_project_path(@extraction_forms_projects_sections_type1.extraction_forms_project,
                                                          'panel-tab': @extraction_forms_projects_sections_type1.extraction_forms_projects_section.id),
                      notice: t('success')
        end
      else
        flash.now[:alert] = @extraction_forms_projects_sections_type1.errors.full_messages[0][6..-1]
        format.html { render :edit }
      end
    end
  end

  private

  def set_extraction_forms_projects_sections_type1
    @extraction_forms_projects_sections_type1 = ExtractionFormsProjectsSectionsType1.find(params[:id])
  end

  def extraction_forms_projects_sections_type1_params
    params.require(:extraction_forms_projects_sections_type1)
          .permit(:type1_type_id, timepoint_name_ids: [], type1_attributes: %i[id name
                                                                               description], timepoint_names_attributes: %i[id name unit])
  end
end
