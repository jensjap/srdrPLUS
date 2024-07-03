class AssignmentsController < ApplicationController
  def update
    assignment = Assignment.find(params[:id])
    return unless assignment.update(strong_params)

    render json: assignment.as_json(include: %i[logs], methods: %i[handles formatted_deadline]), status: 200
  end

  def index
    @assignments = Assignment.where(assignor: current_user).or(Assignment.where(assignee: current_user)).includes(
      :logs, :assignee, :assignor
    )
    projects = Project.joins(:projects_users).where(projects_users: { user: current_user })

    ### Security: must only expose id and handle! ###
    render json: {
      assignments: @assignments.as_json(include: %i[logs], methods: %i[handles formatted_deadline]),
      members: User.joins(projects_users: :project).where(projects:).includes(:profile).distinct.as_json(only: [:id],
                                                                                                         methods: %i[handle]).sort_by { |member| member['handle'] }
    }, status: 200
    ### Security: must only expose id and handle! ###
  end

  def destroy
    assignment = Assignment.find(params[:id])
    return unless assignment.destroy

    render json: {}, status: 200
  end

  def create
    Assignment.createdummy
  end

  private

  def strong_params
    params.permit(:assignor_status, :assignee_status, :assignee_id, :deadline, :archived)
  end
end
