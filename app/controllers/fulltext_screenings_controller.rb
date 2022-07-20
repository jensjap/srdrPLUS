class FulltextScreeningsController < ApplicationController
  add_breadcrumb 'my projects', :projects_path
  skip_before_action :verify_authenticity_token, only: %i[update_word_weight kpis label rescreen]

  before_action :set_project, only: %i[index new create citation_lifecycle_management kpis]
  before_action :set_fulltext_screening, only: %i[update_word_weight label]
  after_action :verify_authorized

  def create
    authorize(@project, policy_class: FulltextScreeningPolicy)
    @fulltext_screening =
      @project.fulltext_screenings.new(fulltext_screening_params)
    if @fulltext_screening.save
      @fulltext_screening.add_citations_from_pool(params[:no_of_citations])
      flash[:notice] = 'Screening was successfully created'
      redirect_to project_fulltext_screenings_path(@project)
    else
      flash[:now] = @fulltext_screening.errors.full_messages.join(',')
      render :new
    end
  end

  def update_word_weight
    authorize(@fulltext_screening.project, policy_class: FulltextScreeningPolicy)
    weight = params[:weight]
    word = params[:word].downcase
    id = params[:id]

    ww = WordWeight.find_by(id:) || WordWeight.find_or_initialize_by(word:, fulltext_screenings_projects_users_role:)
    if params[:destroy]
      ww.destroy
    else
      ww.update(weight:, word:)
    end
    render json: fulltext_screenings_projects_users_role.word_weights_object
  end

  def citation_lifecycle_management
    authorize(@project, policy_class: FulltextScreeningPolicy)
    @citations_projects = CitationsProject.includes(:citation).where(project: @project).page(params[:page]).per(10)
  end

  def destroy
    @fulltext_screening = FulltextScreening.find(params[:id])
    authorize(@fulltext_screening.project, policy_class: FulltextScreeningPolicy)
    if @fulltext_screening.project.fulltext_screenings.first == @fulltext_screening
      flash[:error] = 'The default fulltext screening cannot be deleted.'
    else
      flash[:success] = 'Fulltext screening was deleted.'
      @fulltext_screening.destroy
    end
    redirect_to project_fulltext_screenings_path(@fulltext_screening.project)
  end

  def edit
    @fulltext_screening = FulltextScreening.find(params[:id])
    authorize(@fulltext_screening.project, policy_class: FulltextScreeningPolicy)
  end

  def index
    authorize(@project, policy_class: FulltextScreeningPolicy)
    @fulltext_screenings =
      policy_scope(@project,
                   policy_scope_class: FulltextScreeningPolicy::Scope)
    @fulltext_screenings =
      @fulltext_screenings
      .order(id: :desc)
      .page(params[:page])
      .per(5)
  end

  def kpis
    authorize(@project, policy_class: FulltextScreeningPolicy)
  end

  def label
    payload = label_params[:data]

    @fulltext_screening_result =
      FulltextScreeningResult.find_by(id: payload[:fulltext_screening_result_id])
    authorize(@fulltext_screening_result, policy_class: FulltextScreeningPolicy)
    if @fulltext_screening_result
      @fulltext_screening_result.process_payload(
        payload, fulltext_screenings_projects_users_role
      )
      @fulltext_screenings_citations_project = @fulltext_screening_result.fulltext_screenings_citations_project
      @random_citation = @fulltext_screening_result.citation
    end

    get_next_fulltextion_screening_result if @fulltext_screening_result.nil? || payload[:label_value].present?

    prepare_json_label_data
  end

  def new
    authorize(@project, policy_class: FulltextScreeningPolicy)
    @fulltext_screening = @project.fulltext_screenings.new
  end

  def rescreen
    @fulltext_screening = FulltextScreening.find(params[:fulltext_screening_id])
    asr_id = params[:fulltext_screening_result_id]
    previous = params[:previous]

    session[:fulltext_screening_result_id] =
      if asr_id != 'null' && previous
        FulltextScreeningResult.users_previous_asr_id(asr_id, fulltext_screenings_projects_users_role) || asr_id
      elsif asr_id != 'null'
        FulltextScreeningResult.find(asr_id).user == current_user ? asr_id : nil
      end
    session.delete(:fulltext_screening_result_id) if session[:fulltext_screening_result_id].nil?
    authorize(FulltextScreeningResult.find(session[:fulltext_screening_result_id]),
              policy_class: FulltextScreeningPolicy)
    redirect_to action: :screen
  end

  def screen
    authorize(FulltextScreening.find(params[:fulltext_screening_id]),
              policy_class: FulltextScreeningPolicy)
    render layout: 'abstrackr'
  end

  def show
    @fulltext_screening = FulltextScreening.find(params[:id])
    @project = @fulltext_screening.project
    authorize(@fulltext_screening.project, policy_class: FulltextScreeningPolicy)
    @fulltext_screening_results =
      @fulltext_screening
      .fulltext_screening_results
      .order(created_at: :desc)
      .page(params[:page])
      .per(5)
  end

  def update
    @fulltext_screening = FulltextScreening.find(params[:id])
    @project = @fulltext_screening.project
    authorize(@fulltext_screening.project, policy_class: FulltextScreeningPolicy)
    if @fulltext_screening.update(fulltext_screening_params)
      @fulltext_screening.add_citations_from_pool(params[:no_of_citations].to_i)
      flash[:notice] = 'Screening was successfully updated'
      redirect_to project_fulltext_screenings_path(@project)
    else
      flash[:now] = @fulltext_screening.errors.full_messages.join(',')
      render :edit
    end
  end

  private

  def fulltext_screening_params
    strong_params = params.require(:fulltext_screening).permit(
      :fulltext_screening_type,
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

  def fulltext_screenings_projects_users_role
    @fulltext_screenings_projects_users_role ||=
      FulltextScreeningsProjectsUsersRole.find_aspur(current_user,
                                                     @fulltext_screening)
  end

  def allow_new_reasons(strong_params)
    return strong_params unless strong_params['reason_ids'].present?

    reasons = strong_params['reason_ids']
    strong_params['reason_ids'] = reasons.map do |reason|
      reason == '' || reason[0] != '_' ? reason : Reason.find_or_create_by(name: reason[1..]).id
    end
    strong_params
  end

  def allow_new_tags(strong_params)
    return strong_params unless strong_params['tag_ids'].present?

    tags = strong_params['tag_ids']
    strong_params['tag_ids'] = tags.map do |tag|
      tag == '' || tag[0] != '_' ? tag : Tag.find_or_create_by(name: tag[1..]).id
    end
    strong_params
  end

  def get_next_fulltextion_screening_result
    @asr_id = session[:fulltext_screening_result_id]
    if @asr_id
      session.delete(:fulltext_screening_result_id)
      @fulltext_screening_result = FulltextScreeningResult.find(@asr_id)
      @fulltext_screening = @fulltext_screening_result.fulltext_screening
      @random_citation = @fulltext_screening_result.citation
      @fulltext_screenings_citations_project = @fulltext_screening_result.fulltext_screenings_citations_project
    elsif @fulltext_screening_result = FulltextScreeningResult.find_unfinished_fulltext_screening_result(
      @fulltext_screening, fulltext_screenings_projects_users_role
    )
      @fulltext_screening = @fulltext_screening_result.fulltext_screening
      @random_citation = @fulltext_screening_result.citation
      @fulltext_screenings_citations_project = @fulltext_screening_result.fulltext_screenings_citations_project
    elsif @fulltext_screening.fulltext_screening_type == FulltextScreening::SINGLE_PERPETUAL ||
          @fulltext_screening.fulltext_screening_type == FulltextScreening::DOUBLE_PERPETUAL
      citations_project =
        @fulltext_screening
        .project.citations_projects
        .where(screening_status: CitationsProject::CITATION_POOL)
        .sample
      citations_project.update(screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED)
      @random_citation = citations_project.citation

      @fulltext_screenings_citations_project =
        @fulltext_screening
        .fulltext_screenings_citations_projects
        .find_or_create_by(
          fulltext_screening:
          @fulltext_screening,
          citations_project:
            CitationsProject.find_by(
              project: @fulltext_screening.project, citation: @random_citation
            )
        )

      @fulltext_screening_result =
        @fulltext_screening
        .fulltext_screening_results
        .create!(label: nil, fulltext_screenings_citations_project: @fulltext_screenings_citations_project,
                 fulltext_screenings_projects_users_role:)
    else
      @fulltext_screenings_citations_project =
        FulltextScreeningsCitationsProject
        .joins(:fulltext_screening, :citations_project)
        .left_joins(:fulltext_screening_results)
        .where(fulltext_screening: @fulltext_screening)
        .where(fulltext_screening_results: { label: nil })
        .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING_PARTIALLY_SCREENED }).sample
      @fulltext_screening_result =
        @fulltext_screening
        .fulltext_screening_results
        .create!(label: nil, fulltext_screenings_citations_project: @fulltext_screenings_citations_project,
                 fulltext_screenings_projects_users_role:)
      @random_citation = @fulltext_screening_result.citation
    end
  end

  def label_params
    params
      .permit(
        data: [
          :label_value, :notes, :fulltext_screening_result_id, :rescreen, {
            predefined_reasons: {}, custom_reasons: {}, predefined_tags: {},
            custom_tags: {}, citation: [:fulltext_screenings_citations_project_id]
          }
        ]
      )
  end

  def prepare_json_label_data
    @predefined_reasons = @fulltext_screening.reasons_object
    @predefined_tags = @fulltext_screening.tags_object
    @custom_reasons = fulltext_screenings_projects_users_role.reasons_object
    @custom_tags = fulltext_screenings_projects_users_role.tags_object

    @fulltext_screening_result&.reasons&.each do |reason|
      name = reason.name
      if @predefined_reasons.key?(name)
        @predefined_reasons[name] = true
      else
        @custom_reasons[name] = true
      end
    end

    @fulltext_screening_result&.tags&.each do |tag|
      name = tag.name
      if @predefined_tags.key?(name)
        @predefined_tags[name] = true
      else
        @custom_tags[name] = true
      end
    end
  end

  def set_fulltext_screening
    @fulltext_screening = FulltextScreening.find(params[:fulltext_screening_id])
  end

  def set_project
    @project = Project.includes(citations_projects: :citation).find(params[:project_id])
  end
end
