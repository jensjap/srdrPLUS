class ProjectsUsersController < ApplicationController
  before_action :set_projects_user, only: [ :next_assignment ]
  def next_assignment
    assignments = []
    @projects_user.projects_users_roles.each do |projects_users_role| 
      assignments << projects_users_role.assignments
    end
    @next_assignment = assignments.first
    redirect_to controller: :assignments, action: :screen, id: @next_assignment.id
  end
  private
  def set_projects_users_role
    @projects_users_role = ProjectsUsersRole.find( params[ :id ] )
  end
end
