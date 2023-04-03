class Api::V2::ExtractionFormsProjectsSectionsController < Api::V2::BaseController
  before_action :set_extraction_forms_projects_section, only: [:show]

  resource_description do
    short 'End-points describing Sections within an SRDR+ Extraction Form.'
    formats [:json]
  end

  api :GET, '/v2/extraction_forms_projects_section/:id.json',
      'Returns full description of extraction form section template.'
  param_group :resource_id, Api::V2::BaseController
  def show
    authorize(@extraction_forms_projects_section)
  end

  private

  def set_extraction_forms_projects_section
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:id])
  end
end
