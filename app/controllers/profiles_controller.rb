class ProfilesController < ApplicationController
  before_action :set_profile, :skip_policy_scope, only: [:show, :edit, :update, :destroy]

  # GET /profile
  # GET /profile.json
  def show
    authorize @profile
  end

  # GET /profile/edit
  def edit
    authorize @profile
  end

  # PATCH/PUT /profile
  # PATCH/PUT /profile.json
  def update
    authorize @profile
    respond_to do |format|
      if @profile.update(profile_params)
        format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
        format.json { render :show, status: :ok, location: @profile }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = current_user.profile
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def profile_params
    params.require(:profile)
      .permit(:username, :time_zone,
              :first_name, :middle_name, :last_name,
              :organization_id, :advanced_mode,
              :abstrackr_setting_id,
              :organization_id,
              degree_ids: [])
  end
end
