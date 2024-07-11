class AssignmentsMessagesController < ApplicationController
  def create
    # TODO: authorize
    assignments_message = AssignmentsMessage.create(strong_params)
    render json: assignments_message, status: 200
  end

  def destroy
    # TODO: authorize
    assignments_message = AssignmentsMessage.find(params[:id])
    assignments_message.destroy

    render json: assignments_message, status: 200
  end

  private

  def strong_params
    params.permit(:assignment_id, :message_id)
  end
end
