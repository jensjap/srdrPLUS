class Api::V1::ExtractionFormsProjectsSectionsController < Api::V1::BaseController
  before_action :set_extraction_forms_project, only: [:index]
  before_action :set_extraction_forms_projects_section, only: [:show]

  before_action :skip_authorization, :skip_policy_scope

  def_param_group :extraction_forms_project_section do
    param :extraction_forms_projects_section, Hash, required: true, action_aware: true do
      param :extraction_forms_project_id, Integer, required: true
      param :extraction_forms_projects_section_type_id, Integer, required: true
      param :section, Integer, required: true
    end
  end

  # api :GET, '/v1/extraction_forms_projects/:extraction_forms_project_id/extraction_forms_projects_sections',
  #   'List of sections by extraction form id'
  # formats [:json]
  def index
    @extraction_forms_projects_sections = @extraction_forms_project.extraction_forms_projects_sections
    respond_with @extraction_forms_projects_sections
  end

  # api :GET, '/v1/extraction_forms_projects_sections/:id', 'Show section by id'
  # param_group :extraction_forms_project_section
  def show
    respond_with @extraction_forms_projects_section
  end

  def toggle_hiding
    efps_id = params[:extraction_forms_projects_section_id]
    efps = ExtractionFormsProjectsSection.find(efps_id)
    efps.update(hidden: !efps.hidden)
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
