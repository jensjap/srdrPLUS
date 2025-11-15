class RoomsController < ApplicationController
  def destroy
    room = Room.find(params[:id])
    if room.user == current_user
      room.memberships.each do |membership|
        membership.broadcast_membership(Membership::REMOVE_MEMBERSHIP)
      end
      room.destroy
      render json: room, status: 200
    else
      render json: {}, status: 403
    end
  end

  def create
    respond_to do |format|
      format.json do
        room = Room.new(room_params)
        room.user = current_user
        if room.save && room.users << current_user
          render json: room, status: 200
        else
          render json: {}, status: 403
        end
      end
    end
  end

  private

  def room_params
    params.require(:room).permit(:name)
  end
end
