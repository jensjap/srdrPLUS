class ExternalServiceProvidersProjectsUsersController < ApplicationController
  after_action :verify_authorized
  before_action :set_external_service_providers_projects_user, only: %i[update destroy share]

  def create
    @external_service_providers_projects_user = ExternalServiceProvidersProjectsUser.new(external_service_providers_projects_user_params)
    authorize(@external_service_providers_projects_user.project, policy_class: ExternalServiceProvidersProjectsUserPolicy)
    if @external_service_providers_projects_user.save
      flash.now[:success] = 'Record successfully saved.'
    else
      if @external_service_providers_projects_user.errors.present?
        error_message = @external_service_providers_projects_user.errors.full_messages.join(', ')
      else
        error_message = 'Failed to create record.'
      end
      flash.now[:error] = error_message
    end
    respond_to do |format|
      format.js do
        @project = @external_service_providers_projects_user.project
        @project.external_service_providers_projects_users.build(user: current_user)
      end
    end
  end

  def update
    authorize(@external_service_providers_projects_user)
    if @external_service_providers_projects_user.update(external_service_providers_projects_user_params)
      flash.now[:success] = 'Record successfully saved.'
    else
      if @external_service_providers_projects_user.errors.present?
        error_message = @external_service_providers_projects_user.errors.full_messages.join(', ')
      else
        error_message = 'Failed to save record.'
      end
      flash.now[:error] = error_message
    end
  end

  def destroy
    authorize(@external_service_providers_projects_user)
    if @external_service_providers_projects_user&.destroy
      flash.now[:success] = 'Record successfully deleted.'
    else
      error_message = 'Failed to delete record.'
      error_message += error_message + ' ' + @exception if @exception
      flash.now[:error] = error_message
    end
    respond_to do |format|
      format.js do
        @project = @external_service_providers_projects_user.project
        @project.external_service_providers_projects_users.build(user: current_user)
      end
    end
  end

  def share
    authorize(@external_service_providers_projects_user)
    esp_name = @external_service_providers_projects_user.external_service_provider.name
    @project = @external_service_providers_projects_user.project
    ExternalServiceProvidersProjectsUserShareJob.perform_later(@external_service_providers_projects_user.id, @project.id, current_user.id)
    Event.create(
      sent: current_user.email,
      action: 'Sharing data with External Service Provider',
      resource: @external_service_providers_projects_user.class.to_s,
      resource_id: @external_service_providers_projects_user.id,
      notes: esp_name
    )
    flash.now[:success] = "Request to share project with #{esp_name} has been logged. You will be notified by email of its completion."
    respond_to(&:js)
  end

  private

  def set_external_service_providers_projects_user
    @external_service_providers_projects_user = ExternalServiceProvidersProjectsUser.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    @exception = e
    nil
  end

  def external_service_providers_projects_user_params
    params.require(:external_service_providers_projects_user).permit(:external_service_provider_id, :project_id, :user_id, :api_token)
  end
end
