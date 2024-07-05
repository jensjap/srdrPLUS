class AssignmentsController < ApplicationController
  def update
    # TODO: authorize
    assignment = Assignment.find(params[:id])
    return unless assignment.update(strong_params)

    render json: assignment.as_json(include: %i[logs], methods: %i[handles formatted_deadline]), status: 200
  end

  def index
    # TODO: authorize
    @assignments = Assignment.where(assignor: current_user).or(Assignment.where(assignee: current_user)).includes(
      :logs, :assignee, :assignor
    )
    assignments = @assignments.as_json(include: %i[logs], methods: %i[handles formatted_deadline])
    projects = Project.joins(:projects_users).where(projects_users: { user: current_user })
    users = User.joins(projects_users: :project).where(projects:).includes(:profile).distinct

    ### Security: must only expose id and handle! ###
    members = users.as_json(only: [:id], methods: %i[handle]).sort_by { |member| member['handle'] }
    ### Security: must only expose id and handle! ###

    assignment_rooms_hash = AssignmentsRoom.where(room_id: params[:room_id]).map { |ar| [ar.assignment_id, ar.id] }.to_h
    assignments.each do |assignment|
      assignment['assignments_room_id'] = assignment_rooms_hash[assignment['id']]
    end
    render json: { assignments:, members: }, status: 200
  end

  def destroy
    # TODO: authorize
    assignment = Assignment.find(params[:id])
    return unless assignment.destroy

    render json: {}, status: 200
  end

  def create
    # TODO: authorize
    Assignment.createdummy
  end

  private

  def strong_params
    params.permit(:status, :assignee_id, :deadline, :archived)
  end
end
