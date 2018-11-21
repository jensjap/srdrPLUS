class Api::V1::Type1sController < Api::V1::BaseController
  before_action :set_extraction_forms_projects_section, :skip_policy_scope, :skip_authorization

  def index
    @type1s = @extraction_forms_projects_section.type1s.by_query(params[:q])
  end

  private

    def set_extraction_forms_projects_section
      @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:extraction_forms_projects_section_id])
    end
end
