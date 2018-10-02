class Api::V1::ProjectsUsersRolesController < ApplicationController
  # GET /authors.json
  def index
    _project = Project.find(params[:project_id]) || Project
    @projects_users_roles = _project.projects_users_roles
  end
end

