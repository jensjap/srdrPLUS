class InvitationsController < ApplicationController
  include Behaveable::ResourceFinder
  include Behaveable::RouteExtractor

  # Response type.
  respond_to :json

  # Get invitations.
  #
  # GET (/:invitable/:invitable_id)/invitations(.:format)
  #
  # ==== Returns
  # * <tt>Response</tt> - JSON serialized invitations.
  def index
    @invitations = invitable.all
    respond_with @invitations, status: :ok, location: extract(@behaveable)
  end

  # Get a invitation.
  #
  # GET (/:invitable/:invitable_id)/invitations/:id(.:format)
  #
  # ==== Returns
  # * <tt>Response</tt> - JSON serialized invitation.
  def show
    invitation = invitable.find(params[:id])
    respond_with invitation, status: :ok, location: extract(@behaveable, invitation)
  end

  def new
    invitable
    @existing_invitations = @behaveable.invitations
    #@invitation = @behaveable.invitations.build
  end

  # Create a invitation.
  #
  # POST (/:invitable/:invitable_id)/invitations(.:format)
  #
  # ==== Returns
  # * <tt>Response</tt> - JSON serialized invitation or errors if any.
  def create
    @invitation = invitable.new(invitation_params)
    respond_to do |format|
      @invitation.transaction do
        if @invitation.save
          invitable << @invitation if @behaveable
          format.js
        else
          @invitation.errors[:base] << ['Something went wrong', 'We were not able to create a new team.']
          format.js
        end
      end
    end
  end

  # Update a invitation.
  #
  # PATCH (/:invitable/:invitable_id)/invitations/:id(.:format)
  #
  # ==== Returns
  # * <tt>Response</tt> - JSON serialized invitation or errors if any.
  def update
    invitation = invitable.find(params[:id])
    respond_to do |format|
      if invitation.update(invitation_params)
        format.json { render json: invitation, status: :ok }
      else
        format.json { render errors_for(invitation) }
      end
    end
  end

  # Delete a invitation.
  #
  # DELETE (/:invitable/:invitable_id)/invitations/:id(.:format)
  #
  # ==== Returns
  # * <tt>Response</tt> - 204 no content.
  def destroy
    invitation = invitable.find(params[:id])
    invitation.destroy if invitation
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private

  # Get Invitation context object.
  #
  # ==== Returns
  # * <tt>ActiveRecord</tt> - invitable's invitations or Invitation.
  def invitable
    @behaveable ||= behaveable
    @behaveable ? @behaveable.invitations : Invitation
  end

  # ActiveRecord object errors.
  # TODO: Should be placed at ApplicationController level ??.
  #
  # ==== Parameters
  # * <tt>object</tt> - ActiveRecord object.
  #
  # ==== Returns
  # * <tt>Hash</tt> - Hash containing object errors if any.
  def errors_for(object)
    { json: { errors: object.errors }, status: :unprocessable_entity }
  end

  # Sanitize request data.
  #
  # ==== Returns
  # * <tt>Hash</tt> - Sanitized request params.
  def invitation_params
    params.require(:invitation).permit(:enabled, :role_id, :requires_approval)
  end
end

#class InvitationsController < ApplicationController
#  before_action :set_invitation, only: [:show, :edit, :update, :destroy]
#
#  respond_to :html
#
#  def index
#    @invitations = Invitation.all
#    respond_with(@invitations)
#  end
#
#  def show
#    respond_with(@invitation)
#  end
#
#  def new
#    @invitation = Invitation.new
#    respond_with(@invitation)
#  end
#
#  def edit
#  end
#
#  def create
#    @invitation = Invitation.new(invitation_params)
#    @invitation.save
#    respond_with(@invitation)
#  end
#
#  def update
#    @invitation.update(invitation_params)
#    respond_with(@invitation)
#  end
#
#  def destroy
#    @invitation.destroy
#    respond_with(@invitation)
#  end
#
#  private
#    def set_invitation
#      @invitation = Invitation.find(params[:id])
#    end
#
#    def invitation_params
#      params.require(:invitation).permit(:invitable_id, :invitable_type, :enabled, :role_id)
#    end
#end
