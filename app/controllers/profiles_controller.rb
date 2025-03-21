class ProfilesController < ApplicationController
  before_action :set_profile, :skip_policy_scope, only: %i[show edit update destroy read_storage set_storage toggle_labels_visibility get_labels_visibility toggle_follow_project_settings get_follow_project_settings]
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

  def read_storage
    begin
      JSON.parse(@profile.storage)
    rescue StandardError => e
      @profile.update(storage: {}.to_json)
    end
    render json: @profile.storage, status: 200
  end

  def set_storage
    begin
      old_storage = JSON.parse(@profile.storage)
    rescue StandardError => e
      old_storage = {}
    end

    new_storage = old_storage.merge(request.parameters[:storage])
    @profile.update(storage: new_storage.to_json)
    render json: new_storage, status: 200
  end

  def toggle_labels_visibility
    respond_to do |format|
      if @profile.update(conflict_resolution_label_visibility: params[:show_all_labels])
        format.json { head :no_content }
      else
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_labels_visibility
    render json: { show_all_labels: @profile.conflict_resolution_label_visibility }
  end

  def toggle_follow_project_settings
    respond_to do |format|
      if @profile.update(follow_project_settings_in_conflict_resolution: params[:follow_project_settings])
        format.json { head :no_content }
      else
        format.json { render json: @profile.errors, status: :unprocessable_entity }
      end
    end
  end

  def get_follow_project_settings
    render json: { follow_project_settings: @profile.follow_project_settings_in_conflict_resolution }
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
        :conflict_resolution_label_visibility,
        degree_ids: []
      )
  end
end
