class Api::V2::ExtractionsController < Api::V2::BaseController
  before_action :set_extraction, only: [:show]

  resource_description do
    short 'End-points describing Extractions within an SRDR+ Project.'
    formats [:json]
  end

  def_param_group :extraction do
    property :assigned_user, Hash do
      param_group :user, Api::V2::ProjectsController
    end
    property :id, Integer, desc: 'Resource ID.'
    property :project_id, Integer
    property :citations_project_id, Integer
    property :projects_users_role_id, Integer
    property :consolidated, :boolean
    property :deleted_at, DateTime
    property :created_at, DateTime
    property :updated_at, DateTime
  end

  api :GET, '/v2/extractions/:id.json', 'Returns meta information about a specific extraction.'
  param_group :resource_id, Api::V2::BaseController
  def show
    @project = @extraction.project
    authorize(@project, policy_class: ExtractionPolicy)
  end

  private
    def set_extraction
      @extraction = Extraction.find(params[:id])
    end
end
