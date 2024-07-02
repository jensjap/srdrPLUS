class AssignmentsController < ApplicationController
  def update
    assignment = Assignment.find(params[:id])
    return unless assignment.update(strong_params)

    render json: assignment.to_json(include: %i[logs], methods: %i[handles formatted_deadline]), status: 200
  end

  def index
    @assignments = Assignment.where(assignor: current_user).or(Assignment.where(assignee: current_user)).includes(
      :logs, :assignee, :assignor
    )
    render json: @assignments.to_json(include: %i[logs], methods: %i[handles formatted_deadline])
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
