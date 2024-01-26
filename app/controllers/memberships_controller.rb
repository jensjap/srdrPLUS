class MembershipsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @room = Room.find(params[:room_id])
        @users = @room.users.includes(:profile)
      end
    end
  end
end
