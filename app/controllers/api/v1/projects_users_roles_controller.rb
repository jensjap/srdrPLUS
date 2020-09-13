class Api::V1::ProjectsUsersRolesController < Api::V1::BaseController
  before_action :skip_policy_scope, only: [:index]

  # GET /authors.json
  def index
    @projects_users_roles =
      authorize(
        Project.find(params[:project_id]),
        policy_class: ProjectsUsersRolePolicy
      ).
      projects_users_roles
  end
end
