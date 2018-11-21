class ProjectsUsersRolesController < ApplicationController
  before_action :set_projects_users_role, :skip_policy_scope, only: [:next_assignment]

  def next_assignment
    authorize(@projects_users_role.project, policy_class: ProjectsUsersRolePolicy)

    @next_assignment = @projects_users_role.assignments.first
    redirect_to controller: :assignments, action: :screen, id: @next_assignment.id
  end

  private

  def set_projects_users_role
    @projects_users_role = ProjectsUsersRole.find( params[ :id ] )
  end
end
