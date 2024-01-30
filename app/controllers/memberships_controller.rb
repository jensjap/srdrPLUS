class MembershipsController < ApplicationController
  def index
    # TODO: authorize
    respond_to do |format|
      format.json do
        @room = Room.includes(project: :users).find(params[:room_id])
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
          membership.broadcast_membership(Membership::REMOVE_MEMBERSHIP)
          @room = membership.room
          @memberships = @room.memberships.includes(user: :profile)
          render :index
        else
          render json: {}, status: 403
        end
      end
    end
  end

  def create
    # TODO: authorize
    respond_to do |format|
      format.json do
        membership = Membership.new(membership_params)
        if membership.save
          membership.broadcast_membership(Membership::ADD_MEMBERSHIP)
          @room = membership.room
          @memberships = @room.memberships.includes(user: :profile)
          render :index
        else
          render json: {}, status: 403
        end
      end
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:user_id, :room_id)
  end
end
