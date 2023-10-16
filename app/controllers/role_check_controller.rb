class RoleCheckController < ApplicationController
  def check_role
    screenings_type = params[:screenings_type]
    project_id = params[:project_id]

    projects_user = ProjectsUser.find_by(project_id: project_id, user_id: current_user.id)
    check_condition = projects_user&.project_contributor? && !projects_user&.project_leader? && !projects_user&.project_consolidator?

    redirect_url = if screenings_type == "abstract"
                     work_selection_project_abstract_screenings_path(project_id)
                   elsif screenings_type == "fulltext"
                     work_selection_project_fulltext_screenings_path(project_id)
                   end

    render json: { check_condition: check_condition, redirect_url: redirect_url }
  end
end
