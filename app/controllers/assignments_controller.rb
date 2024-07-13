class AssignmentsController < ApplicationController
  def new
    extractions = Extraction.joins(project: :projects_users).where(projects_users: { user: current_user }).includes(:assignments)
    render json: extractions.as_json(include: { assignments: { methods: :name } }), status: 200
  end

  def update
    # TODO: authorize
    assignment = Assignment.find(params[:id])
    return unless assignment.update(strong_params)

    render json: assignment.as_json(include: %i[logs messages], methods: %i[name handles formatted_deadline]), status: 200
  end

  def index
    # TODO: authorize
    @assignments = Assignment.where(assignor: current_user).or(Assignment.where(assignee: current_user)).includes(
      :logs, :assignee, :assignor, :messages
    )
    assignments = @assignments.as_json(include: %i[logs messages], methods: %i[name handles formatted_deadline])
    projects = Project.joins(:projects_users).where(projects_users: { user: current_user })
    users = User.joins(projects_users: :project).where(projects:).includes(:profile).distinct

    # Security: must only expose id and handle! ###
    members = users.map { |user| { id: user.id, handle: user.handle }}.sort_by { |member| member['handle'] }

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
