class AbstractScreeningsController < ApplicationController
  add_breadcrumb 'my projects', :projects_path

  before_action :set_project, only: %i[index new create]
  def index
    @up = @project.citations_projects.where(citations_projects: { screening_status: nil })
    @as = @project.citations_projects.where(citations_projects: { screening_status: 'AS' })
    @fs = @project.citations_projects.where(citations_projects: { screening_status: 'FS' })
    @de = @project.citations_projects.where(citations_projects: { screening_status: 'DE' })
  end

  def new
    @abstract_screening = @project.abstract_screenings.new
  end

  def create
    @abstract_screening = @project.abstract_screenings.new(abstract_screening_params)
    if @abstract_screening.save
      @abstract_screening.add_citations_from_pool(params[:no_of_citations])
      flash[:notice] = 'Screening was successfully created'
      redirect_to project_abstract_screenings_path(@project)
    else
      flash[:now] = @abstract_screening.errors.full_messages.join(',')
      render :new
    end
  end

  def show
    @abstract_screening = AbstractScreening.find(params[:id])
  end

  def screening
    @abstract_screening = AbstractScreening.find(params[:abstract_screening_id])
    render layout: 'abstrackr'
  end

  private

  def set_project
    @project = Project.includes(citations_projects: :citation).find(params[:project_id])
  end

  def abstract_screening_params
    strong_params = params.require(:abstract_screening).permit(
      :abstract_screening_type,
      :yes_tag_required,
      :no_tag_required,
      :maybe_tag_required,
      :yes_reason_required,
      :no_reason_required,
      :maybe_reason_required,
      :yes_note_required,
      :no_note_required,
      :maybe_note_required,
      :hide_author,
      :hide_journal,
      projects_users_role_ids: [],
      reason_ids: [],
      tag_ids: []
    )
    allow_new_tags(strong_params)
    allow_new_reasons(strong_params)
  end

  def allow_new_tags(strong_params)
    return strong_params unless strong_params['tag_ids'].present?

    tags = strong_params['tag_ids']
    strong_params['tag_ids'] = tags.map do |tag|
      tag == '' || tag[0] != '_' ? tag : Tag.find_or_create_by(name: tag[1..]).id
    end
    strong_params
  end

  def allow_new_reasons(strong_params)
    return strong_params unless strong_params['reason_ids'].present?

    reasons = strong_params['reason_ids']
    strong_params['reason_ids'] = reasons.map do |reason|
      reason == '' || reason[0] != '_' ? reason : Reason.find_or_create_by(name: reason[1..]).id
    end
    strong_params
  end
end
