class InvitationsController < ApplicationController
  before_action :set_invitation, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @invitations = Invitation.all
    respond_with(@invitations)
  end

  def show
    respond_with(@invitation)
  end

  def new
    @invitation = Invitation.new
    respond_with(@invitation)
  end

  def edit
  end

  def create
    @invitation = Invitation.new(invitation_params)
    @invitation.save
    respond_with(@invitation)
  end

  def update
    @invitation.update(invitation_params)
    respond_with(@invitation)
  end

  def destroy
    @invitation.destroy
    respond_with(@invitation)
  end

  private
    def set_invitation
      @invitation = Invitation.find(params[:id])
    end

    def invitation_params
      params.require(:invitation).permit(:invitable_id, :invitable_type, :enable, :role_id)
    end
end
