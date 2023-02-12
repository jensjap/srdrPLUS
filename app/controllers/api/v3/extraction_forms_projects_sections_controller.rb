class Api::V3::ExtractionFormsProjectsSectionsController < Api::V3::BaseController
  before_action :set_extraction_forms_project, only: [:index]

  def index
    @extraction_forms_projects_sections = ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_project_id(@extraction_forms_project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @extraction_forms_projects_sections }
      format.fhir_json { render json: @extraction_forms_projects_sections }
      format.html { render json: @extraction_forms_projects_sections }
      format.json { render json: @extraction_forms_projects_sections }
      format.xml { render xml: @extraction_forms_projects_sections }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  def show
    @extraction_forms_projects_section = ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_projects_section_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @extraction_forms_projects_section }
      format.fhir_json { render json: @extraction_forms_projects_section }
      format.html { render json: @extraction_forms_projects_section }
      format.json { render json: @extraction_forms_projects_section }
      format.xml { render xml: @extraction_forms_projects_section }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  private

    def set_extraction_forms_project
      @extraction_forms_project = ExtractionFormsProject.find(params[:extraction_forms_project_id])
    end

end
