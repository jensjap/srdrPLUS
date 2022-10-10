class ProfilesController < ApplicationController
  before_action :set_profile, :skip_policy_scope, only: %i[show edit update destroy]
  before_action :call_authorize

  # GET /profile
  # GET /profile.json
  def show; end

  # GET /profile/edit
  def edit
    @nav_buttons.push('account')
  end

  # PATCH/PUT /profile
  # PATCH/PUT /profile.json
  def update
    respond_to do |format|
      if @profile.update(profile_params)
        format.html do
          redirect_to edit_user_registration_path(@profile.user), notice: 'Profile was successfully updated.'
        end
        format.json { render :show, status: :ok, location: edit_user_registration_path(@profile.user) }
        format.js   { render inline: 'location.reload();' }
      else
        format.html { render :edit }
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def call_authorize
    authorize @profile
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_profile
    @profile = current_user.profile
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def profile_params
    params
      .require(:profile)
      .permit(
        :username,
        :time_zone,
        :first_name,
        :middle_name,
        :last_name,
        :advanced_mode,
        :projects_paginate_per,
        :organization_id,
        :abstrackr_setting_id,
        :organization_id,
        degree_ids: []
      )
  end
end
