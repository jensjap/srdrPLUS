class PublishingsController < ApplicationController
  SD_META_DATUM = 'sd_meta_datum'

  before_action :set_publishable_model, only: [:create, :approve]
  before_action :set_publishing, only: [:approve, :destroy]

  def create
    return render body: nil, :status => :bad_request unless @publishable_model && @publishable_model.publishing.nil?

    errors = @publishable_model.check_publishing_eligibility
    if errors.present?
      flash[:errors] = "Some required fields are missing. Please go to the SR 360 record to fill out all required fields: #{errors.join(', ')}"
    else
      @publishable_model.publishing = Publishing.create(user: current_user)
      PublishingMailer.notify_admin_of_request(publishing.publishable.display, publishing.name_of_pub_type, publishing.id).deliver_later
      PublishingMailer.notify_publisher_of_request(current_user.email, publishing.publishable.display, publishing.name_of_pub_type, publishing.id).deliver_later
      flash[:success] = "Success! Your request is received. We will inform you once the SR 360 for this project is public."
    end

    redirect_back fallback_location: root_path
  end

  def approve
    return render body: nil, :status => :bad_request unless @publishable_model

    if !current_user.admin?
      flash[:error] = "You are not authorized to approve this publication."
    elsif @publishing.nil?
      flash[:error] = "Publishing not found."
    elsif @publishing.approval.present?
      flash[:error] = "Publishing already approved."
    else
      Approval.create!(approvable: @publishing, user: current_user)
      flash[:success] = "The publication has been approved!"
    end

    return redirect_to '/projects'
  end

  def destroy
    if @publishing && @publishing.user == current_user && @publishing.destroy
      flash[:success] = "Success! Your publication request was cancelled."
    else
      flash[:error] = "This publication does not exist or you are not authorized to cancel it."
    end

    return redirect_to '/projects'
  end

  private
    def set_publishing
      @publishing = Publishing.find_by(publishable_id: params[:id])
    end

    def set_publishable_model
      publishable_type = params[:type]

      if publishable_type == SD_META_DATUM
        @publishable_model = SdMetaDatum.find(params[:id])
      end
    end
end
