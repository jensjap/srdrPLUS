class AssignmentsController < ApplicationController
  def index
    @assignments = Assignment.where(assignor: current_user).or(Assignment.where(assignee: current_user)).includes(
      :logs, :assignee, :assignor
    )
    render json: @assignments.to_json(include: %i[logs], methods: [:handles, :formatted_deadline])
  end
end
