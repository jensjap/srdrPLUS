class AbstractScreeningsController < ApplicationController
  add_breadcrumb 'my projects', :projects_path
  skip_before_action :verify_authenticity_token, only: [:label]

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

  def screen
    @abstract_screening = AbstractScreening.find(params[:abstract_screening_id])
    @random_citation = if @abstract_screening.citations.empty?
                         @abstract_screening.project.citations_projects.where(screening_status: nil).sample(1).first.citation
                       else
                         @abstract_screening.citations.sample
                       end
    render layout: 'abstrackr'
  end

  def label
    label_preparations
    payload = params[:data]
    if payload[:labelData]
      label = payload[:labelData][:labelValue]
      abstract_screenings_citations_project_id = payload[:citation][:abstract_screenings_citations_project_id]
      abstract_screening = @abstract_screening
      abstract_screenings_projects_users_role_id = AbstractScreeningsProjectsUsersRole.where(abstract_screening:).first.id ## TODO: rethink user relationship
      @abstract_screening
        .abstract_screening_results
        .create!(label:, abstract_screenings_citations_project_id:,
                 abstract_screenings_projects_users_role_id:)
    end

    render_label_json_data
  end

  def destroy
    @abstract_screening = AbstractScreening.find(params[:id])
    @abstract_screening.destroy
    redirect_to project_abstract_screenings_path(@abstract_screening.project)
  end

  private

  def label_preparations
    @abstract_screening = AbstractScreening.find(params[:abstract_screening_id])

    @abstract_screenings_citations_project = @abstract_screening.abstract_screenings_citations_projects.sample
    @random_citation = @abstract_screenings_citations_project.citation
  end

  def render_label_json_data
    render json: {
      abstract_screening_id: @abstract_screening.id,
      abstract_screenings_citations_project_id: @abstract_screenings_citations_project.id,
      title: @random_citation.name,
      journal: @random_citation.journal.name,
      authors: @random_citation.author_map_string,
      abstract: @random_citation.abstract,
      keywords: @random_citation.keywords.map(&:name).join(','),
      id: @random_citation.accession_number_alts
    }
  end

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
      :only_predefined_reasons,
      :only_predefined_tags,
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
