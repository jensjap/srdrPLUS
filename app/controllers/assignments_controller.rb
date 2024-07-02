class AssignmentsController < ApplicationController
  def index
    @assignments = Assignment.where(assignor: current_user).or(Assignment.where(assignee: current_user)).includes(:logs)
    render json: @assignments.to_json(include: :logs)
  end
end
