class AssignmentsRoomsController < ApplicationController
  def create
    # TODO: authorize
    assignments_room = AssignmentsRoom.create(strong_params)
    render json: assignments_room, status: 200
  end

  def destroy
    # TODO: authorize
    assignments_room = AssignmentsRoom.find(params[:id])
    assignments_room.destroy

    render json: assignments_room, status: 200
  end

  private

  def strong_params
    params.permit(:assignment_id, :room_id)
  end
end
