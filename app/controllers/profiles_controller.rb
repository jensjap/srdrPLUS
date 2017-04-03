class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :edit, :update, :destroy]

  # GET /profile
  # GET /profile.json
  def show
  end

  # GET /profile/edit
  def edit
  end

  # PATCH/PUT /profile
  # PATCH/PUT /profile.json
  def update
    respond_to do |format|
      # Let's save the current organization choice so we can revert in case there's a problem later.
      current_organization = @profile.organization
      @profile.assign_attributes(profile_params)
      update_organization
      if @profile.save
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @profile }
      else
        @profile.organization = current_organization
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Update @profile.organization if a suggestion was made.
  def update_organization
    if params[:profile][:suggested][:organization].present?
      @profile.organization = Organization.add_suggested_resource(params[:profile][:suggested][:organization])
    end
  end

#  # Determine whether form was submitted with suggestions. Suggestions always have id=1.
#  #
#  # Params: [:symbol] Model class name
#  # Returns: [:boolean]
#  def includes_suggested?(resource)
#    resource_id = profile_params[(resource.to_s + '_id').to_sym]
#    resource.to_s.capitalize.constantize.find(resource_id.to_i).id == 1
#  end

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    # Every user should have a profile, build for a new user.
    @profile = current_user.profile
  end

  def profile_params
    # Never trust parameters from the scary internet, only allow the white list through.
    params.require(:profile).permit(:username, :first_name, :middle_name, :last_name,
                                    :organization_id,
                                    degree_ids: []
    )
  end
end

