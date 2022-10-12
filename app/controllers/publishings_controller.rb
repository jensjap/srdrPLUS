class PublishingsController < ApplicationController
  before_action :set_publishable_record, only: %i[new create approve rescind_approval]
  before_action :set_publishing, only: %i[approve rescind_approval destroy]

  def new
    authorize(@project, policy_class: PublishingPolicy)
    @nav_buttons.push('my_projects', 'publication')
    @publishing = Publishing.new(publishable: @publishable_record)
  end

  def create
    unless @publishable_record
      flash[:error] = 'Invalid record to publish.'
      return redirect_to '/projects'
    end
    authorize(@project, policy_class: PublishingPolicy)

    errors = @publishable_record.check_publishing_eligibility
    if errors.present?
      flash[:errors] =
        "Some required fields are missing. Please go to the record to fill out all required fields: #{errors.join(', ')}"
    elsif @publishable_record.publishing.present?
      flash[:notice] = 'Your request has already been received.'
    elsif @publishable_record.publishing.present? && @publishable_record.publishing.approval.present?
      flash[:notice] = 'Your request has already been received.'
    else
      publishing = Publishing.create(publishable: @publishable_record, user: current_user)
      PublishingMailer
        .notify_admin_of_request(
          publishing.publishable.display,
          publishing.name_of_pub_type,
          publishing.id,
          @publishable_record.id
        ).deliver_later
      PublishingMailer
        .notify_publisher_of_request(
          current_user.email,
          publishing.publishable.display,
          publishing.name_of_pub_type,
          publishing.id,
          @publishable_record.id
        ).deliver_later
      flash[:success] = 'Success! Your request is received. We will inform you once the record is public.'
    end

    redirect_to '/projects?project_status=pending'
  end

  def approve
    return render body: nil, status: :bad_request unless @publishable_record

    if !current_user.admin?
      flash[:error] = 'You are not authorized to approve this publication.'
    elsif @publishing.nil?
      flash[:error] = 'Publishing not found.'
    elsif @publishing.approval.present?
      flash[:error] = 'Publishing already approved.'
    else
      Approval.create!(approvable: @publishing, user: current_user)
      flash[:success] = 'The publication has been approved!'
    end

    redirect_to '/projects?project_status=published'
  end

  def rescind_approval
    return render body: nil, status: :bad_request unless @publishable_record

    if !current_user.admin?
      flash[:error] = 'You are not authorized to approve this publication.'
    elsif @publishing.nil?
      flash[:error] = 'Publishing not found.'
    elsif @publishing.approval.nil?
      flash[:error] = "Publishing hasn't been approved."
    else
      @publishing.approval.destroy
      flash[:success] = 'The publication approval has been rescinded!'
    end

    redirect_to '/projects?project_status=pending'
  end

  def destroy
    if @publishing && @publishing.user == current_user && @publishing.destroy
      flash[:success] = 'Success! Your publication request was cancelled.'
    else
      flash[:error] = 'This publication does not exist or you are not authorized to cancel it.'
    end

    redirect_to '/projects'
  end

  private

  def set_publishing
    @publishing = Publishing.find_by(publishable_id: params[:id])
  end

  def set_publishable_record
    publishable_type = params[:type]

    if publishable_type == SdMetaDatum.to_s
      @publishable_record = SdMetaDatum.find(params[:id])
      @project = @publishable_record.project
    elsif publishable_type == Project.to_s
      @publishable_record = Project.find(params[:id])
      @project = @publishable_record
    end
  end
end
