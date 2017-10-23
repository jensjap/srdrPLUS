class Api::V1::ExtractionFormsProjectsSectionsController < Api::V1::BaseController
  before_action :set_extraction_forms_project, only: [:index]
  before_action :set_extraction_forms_projects_section, only: [:show]

  def index
    @extraction_forms_projects_sections = @extraction_forms_project.extraction_forms_projects_sections
    respond_with @extraction_forms_projects_sections
  end

  def show
    respond_with @extraction_forms_projects_section
  end

  private

    def set_extraction_forms_project
      @extraction_forms_project = ExtractionFormsProject.includes(extraction_forms_projects_sections: [:extraction_forms_projects_section_type,
                                                                                                       :section,
                                                                                                       :extraction_forms_projects_section_type2s])
                                                        .find(params[:extraction_forms_project_id])
    end

    def set_extraction_forms_projects_section
      @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:id])
    end
end
