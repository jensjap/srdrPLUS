class MembershipsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @room = Room.find(params[:room_id])
        authorize(@room, policy_class: MembershipPolicy)

        @memberships = @room.memberships.includes(user: :profile)
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        membership = Membership.find(params[:id])
        authorize(membership.room, policy_class: MembershipPolicy)

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
    respond_to do |format|
      format.json do
        membership = Membership.new(membership_params)
        authorize(membership.room, policy_class: MembershipPolicy)

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
