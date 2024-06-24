class AssignmentsController < ApplicationController
  def index
    @assignments = Assignment.where(assignor: current_user).or(Assignment.where(assignee: current_user))
    render json: @assignments
  end
end
