class MembershipsController < ApplicationController
  def index
    # TODO: authorize
    respond_to do |format|
      format.json do
        @room = Room.find(params[:room_id])
        @memberships = @room.memberships.includes(user: :profile)
      end
    end
  end

  def destroy
    # TODO: authorize
    respond_to do |format|
      format.json do
        membership = Membership.find(params[:id])
        if membership.destroy
          @room = membership.room
          @memberships = @room.memberships.includes(user: :profile)
          render :index
        else
          render json: {}, status: 403
        end
      end
    end
  end
end
