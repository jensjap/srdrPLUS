class ExtractionFormsProjectsSectionsType1sController < ApplicationController
  before_action :set_extraction_forms_projects_sections_type1, only: [:edit, :update]

  def edit
    add_breadcrumb 'my projects',  :projects_path
    add_breadcrumb 'edit project', edit_project_path(@extraction_forms_projects_sections_type1.project)
    add_breadcrumb 'builder',      build_extraction_forms_project_path(@extraction_forms_projects_sections_type1.extraction_forms_project,
                                                                       anchor: "panel-tab-#{ @extraction_forms_projects_sections_type1.extraction_forms_projects_section.id }")
    add_breadcrumb "edit #{ @extraction_forms_projects_sections_type1.section_name.titleize.singularize.downcase } suggestion", edit_extraction_forms_projects_sections_type1_path
  end

  def update
    respond_to do |format|
      if @extraction_forms_projects_sections_type1.update(extraction_forms_projects_sections_type1_params)
        format.html { redirect_to build_extraction_forms_project_path(@extraction_forms_projects_sections_type1.extraction_forms_project,
                                                                      anchor: "panel-tab-#{ @extraction_forms_projects_sections_type1.extraction_forms_projects_section.id }"),
        notice: t('success') }
      end
    end
  end

  private

    def set_extraction_forms_projects_sections_type1
      @extraction_forms_projects_sections_type1 = ExtractionFormsProjectsSectionsType1.find(params[:id])
    end

    def extraction_forms_projects_sections_type1_params
      params.require(:extraction_forms_projects_sections_type1)
        .permit(:type1_type_id, timepoint_name_ids: [], type1_attributes: [:id, :name, :description], timepoint_names_attributes: [:id, :name, :unit])
    end
end
