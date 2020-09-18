class PublishingsController < ApplicationController
  before_action :set_publishable_record, only: [:create, :approve]
  before_action :set_publishing, only: [:approve, :destroy]

  def create
    unless @publishable_record && @publishable_record.publishing.nil?
      flash[:error] = "Invalid record to publish."
      return redirect_to '/projects'
    end

    errors = @publishable_record.check_publishing_eligibility
    if errors.present?
      flash[:errors] = "Some required fields are missing. Please go to the record to fill out all required fields: #{errors.join(', ')}"
    elsif @publishing.present?
      flash[:notice] = "Your request has already been received."
    else
      publishing = Publishing.create(publishable: @publishable_record, user: current_user)
      PublishingMailer.
        notify_admin_of_request(
          publishing.publishable.display, 
          publishing.name_of_pub_type, 
          publishing.id, 
          @publishable_record.id
        ).deliver_now
      PublishingMailer.
        notify_publisher_of_request(
          current_user.email, 
          publishing.publishable.display, 
          publishing.name_of_pub_type, 
          publishing.id, 
          @publishable_record.id
        ).deliver_now
      flash[:success] = "Success! Your request is received. We will inform you once the record is public."
    end

    return redirect_to '/projects'
  end

  def approve
    return render body: nil, :status => :bad_request unless @publishable_record

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

    def set_publishable_record
      publishable_type = params[:type]

      if publishable_type == Publishing::SD_META_DATUM
        @publishable_record = SdMetaDatum.find(params[:id])
      elsif publishable_type == Publishing::PROJECT
        @publishable_record = Project.find(params[:id])
      end
    end
end
