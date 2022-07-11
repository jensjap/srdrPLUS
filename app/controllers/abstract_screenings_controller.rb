class AbstractScreeningsController < ApplicationController
  add_breadcrumb 'my projects', :projects_path
  skip_before_action :verify_authenticity_token, only: %i[label create_word_weight rescreen]

  before_action :set_project, only: %i[index new create citation_lifecycle_management]
  before_action :set_abstract_screening, only: %i[create_word_weight label]
  after_action :verify_authorized

  def create
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @abstract_screening =
      @project.abstract_screenings.new(abstract_screening_params)
    if @abstract_screening.save
      @abstract_screening.add_citations_from_pool(params[:no_of_citations])
      flash[:notice] = 'Screening was successfully created'
      redirect_to project_abstract_screenings_path(@project)
    else
      flash[:now] = @abstract_screening.errors.full_messages.join(',')
      render :new
    end
  end

  def create_word_weight
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
    weight = params[:weight]
    word = params[:word].downcase

    ww = WordWeight.find_or_initialize_by(word:, abstract_screenings_projects_users_role:)
    ww.update(weight:)
    render json: abstract_screenings_projects_users_role.word_weights_object
  end

  def citation_lifecycle_management
    authorize(@project, policy_class: AbstractScreeningPolicy)
    prepare_pipeline_stats
    @citations = @project.citations.page(params[:page]).per(10)
  end

  def destroy
    @abstract_screening = AbstractScreening.find(params[:id])
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
    @abstract_screening.destroy
    redirect_to project_abstract_screenings_path(@abstract_screening.project)
  end

  def index
    authorize(@project, policy_class: AbstractScreeningPolicy)
    prepare_pipeline_stats
    @abstract_screenings =
      policy_scope(@project,
                   policy_scope_class: AbstractScreeningPolicy::Scope)
    @abstract_screenings =
      @abstract_screenings
      .order(id: :desc)
      .page(params[:page])
      .per(5)
  end

  def label
    payload = label_params[:data]

    @abstract_screening_result =
      AbstractScreeningResult.find_by(id: payload[:abstract_screening_result_id])
    authorize(@abstract_screening_result, policy_class: AbstractScreeningPolicy)
    if @abstract_screening_result
      @abstract_screening_result.process_payload(
        payload, abstract_screenings_projects_users_role
      )
      @abstract_screenings_citations_project = @abstract_screening_result.abstract_screenings_citations_project
      @random_citation = @abstract_screening_result.citation
    end

    get_next_abstraction_screening_result if @abstract_screening_result.nil? || payload[:label_value].present?

    render_label_json_data
  end

  def new
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @abstract_screening = @project.abstract_screenings.new
  end

  def rescreen
    @abstract_screening = AbstractScreening.find(params[:abstract_screening_id])
    asr_id = params[:abstract_screening_result_id]
    previous = params[:previous]

    session[:abstract_screening_result_id] =
      if asr_id != 'null' && previous
        AbstractScreeningResult
          .where(abstract_screenings_projects_users_role:)
          .where('updated_at < ?', AbstractScreeningResult.find(asr_id).updated_at)
          .where('label IS NOT NULL')
          .order(updated_at: :desc)
          .limit(1)&.first&.id || asr_id
      elsif asr_id != 'null'
        AbstractScreeningResult.find(asr_id).user == current_user ? asr_id : nil
      else
        AbstractScreeningResult
          .where(abstract_screenings_projects_users_role:)
          .where('label IS NOT NULL')
          .order(updated_at: :desc)
          .limit(1)&.first&.id
      end
    session.delete(:abstract_screening_result_id) if session[:abstract_screening_result_id].nil?
    authorize(AbstractScreeningResult.find(session[:abstract_screening_result_id]),
              policy_class: AbstractScreeningPolicy)
    redirect_to action: :screen
  end

  def screen
    authorize(AbstractScreening.find(params[:abstract_screening_id]),
              policy_class: AbstractScreeningPolicy)
    render layout: 'abstrackr'
  end

  def show
    @abstract_screening = AbstractScreening.find(params[:id])
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
    @abstract_screening_results =
      @abstract_screening
      .abstract_screening_results
      .order(created_at: :desc)
      .page(params[:page])
      .per(5)
  end

  private

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

  def abstract_screenings_projects_users_role
    AbstractScreeningsProjectsUsersRole.find_aspur(current_user, @abstract_screening)
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

  def get_next_abstraction_screening_result
    @asr_id = session[:abstract_screening_result_id]
    if @asr_id
      session.delete(:abstract_screening_result_id)
      @abstract_screening_result = AbstractScreeningResult.find(@asr_id)
      @abstract_screening = @abstract_screening_result.abstract_screening
      @random_citation = @abstract_screening_result.citation
      @abstract_screenings_citations_project = @abstract_screening_result.abstract_screenings_citations_project
    elsif @abstract_screening_result = AbstractScreeningResult.find_unfinished_abstract_screening_result(
      @abstract_screening, abstract_screenings_projects_users_role
    )
      @abstract_screening = @abstract_screening_result.abstract_screening
      @random_citation = @abstract_screening_result.citation
      @abstract_screenings_citations_project = @abstract_screening_result.abstract_screenings_citations_project
    elsif @abstract_screening.abstract_screening_type == AbstractScreening::SINGLE_PERPETUAL ||
          @abstract_screening.abstract_screening_type == AbstractScreening::DOUBLE_PERPETUAL
      citations_project =
        @abstract_screening
        .project.citations_projects
        .where('screening_status IS NULL')
        .sample
      citations_project.update(screening_status: CitationsProject::ABSTRACT_SCREENING)
      @random_citation = citations_project.citation

      @abstract_screenings_citations_project =
        @abstract_screening
        .abstract_screenings_citations_projects
        .find_or_create_by(
          abstract_screening:
          @abstract_screening,
          citations_project:
            CitationsProject.find_by(
              project: @abstract_screening.project, citation: @random_citation
            )
        )

      @abstract_screening_result =
        @abstract_screening
        .abstract_screening_results
        .create!(label: nil, abstract_screenings_citations_project: @abstract_screenings_citations_project,
                 abstract_screenings_projects_users_role:)
    else
      @abstract_screenings_citations_project =
        AbstractScreeningsCitationsProject
        .joins(:abstract_screening, :citations_project)
        .left_joins(:abstract_screening_results)
        .where(abstract_screening: @abstract_screening)
        .where(abstract_screening_results: { label: nil })
        .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING }).sample
      @abstract_screening_result =
        @abstract_screening
        .abstract_screening_results
        .create!(label: nil, abstract_screenings_citations_project: @abstract_screenings_citations_project,
                 abstract_screenings_projects_users_role:)
      @random_citation = @abstract_screening_result.citation
    end
  end

  def label_params
    params
      .permit(
        data: [
          :label_value, :notes, :abstract_screening_result_id, :rescreen, {
            predefined_reasons: {}, custom_reasons: {}, predefined_tags: {},
            custom_tags: {}, citation: [:abstract_screenings_citations_project_id]
          }
        ]
      )
  end

  def prepare_pipeline_stats
    @up = @project
          .citations_projects
          .where(citations_projects: { screening_status: CitationsProject::CITATION_POOL })
    @as = @project
          .citations_projects
          .where(citations_projects: { screening_status: CitationsProject::ABSTRACT_SCREENING })
    @fs = @project
          .citations_projects
          .where(citations_projects: { screening_status: CitationsProject::FULLTEXT_SCREENING })
    @de = @project
          .citations_projects
          .where(citations_projects: { screening_status: CitationsProject::DATA_EXTRACTION })
  end

  def render_label_json_data
    predefined_reasons = @abstract_screening.reasons_object
    predefined_tags = @abstract_screening.tags_object
    custom_reasons = abstract_screenings_projects_users_role.reasons_object
    custom_tags = abstract_screenings_projects_users_role.tags_object

    @abstract_screening_result&.reasons&.each do |reason|
      name = reason.name
      if predefined_reasons.key?(name)
        predefined_reasons[name] = true
      else
        custom_reasons[name] = true
      end
    end

    @abstract_screening_result&.tags&.each do |tag|
      name = tag.name
      if predefined_tags.key?(name)
        predefined_tags[name] = true
      else
        custom_tags[name] = true
      end
    end

    render json: {
      predefined_reasons:,
      predefined_tags:,
      custom_reasons:,
      custom_tags:,
      notes: @abstract_screening_result.note&.value || '',
      label_value: @abstract_screening_result.label,
      word_weights: abstract_screenings_projects_users_role.word_weights_object,
      rescreen: @asr_id,
      abstract_screening_result_id: @abstract_screening_result.id,
      citation: {
        abstract_screening_id: @abstract_screening.id,
        abstract_screenings_citations_project_id: @abstract_screenings_citations_project.id,
        title: @random_citation.name,
        journal: @abstract_screening.hide_journal ? '<hidden>' : @random_citation.journal.name,
        authors: @abstract_screening.hide_author ? '<hidden>' : @random_citation.author_map_string,
        abstract: @random_citation.abstract,
        keywords: @random_citation.keywords.map(&:name).join(','),
        id: @random_citation.accession_number_alts
      },
      options: {
        yes_tag_required: @abstract_screening.yes_tag_required,
        no_tag_required: @abstract_screening.no_tag_required,
        maybe_tag_required: @abstract_screening.maybe_tag_required,
        yes_reason_required: @abstract_screening.yes_reason_required,
        no_reason_required: @abstract_screening.no_reason_required,
        maybe_reason_required: @abstract_screening.maybe_reason_required,
        yes_note_required: @abstract_screening.yes_note_required,
        no_note_required: @abstract_screening.no_note_required,
        maybe_note_required: @abstract_screening.maybe_note_required,
        only_predefined_reasons: @abstract_screening.only_predefined_reasons,
        only_predefined_tags: @abstract_screening.only_predefined_tags
      }
    }
  end

  def set_abstract_screening
    @abstract_screening = AbstractScreening.find(params[:abstract_screening_id])
  end

  def set_project
    @project = Project.includes(citations_projects: :citation).find(params[:project_id])
  end
end
