class ProjectsUsersRolesController < ApplicationController
  before_action :set_projects_users_role, only: [ :next_assignment ]
  def next_assignment
    @next_assignment = @projects_users_role.assignments.first
    redirect_to controller: :assignments, action: :screen, id: @next_assignment.id
  end
  private
  def set_projects_users_role
    @projects_users_role = ProjectsUsersRole.find( params[ :id ] )
  end
end
