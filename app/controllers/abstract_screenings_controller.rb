class AbstractScreeningsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update_word_weight kpis]

  before_action :set_project, only: %i[index new create citation_lifecycle_management export_screening_data kpis]
  before_action :set_abstract_screening, only: %i[update_word_weight screen]
  after_action :verify_authorized

  def new
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @abstract_screening = @project.abstract_screenings.new
  end

  def create
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @abstract_screening =
      @project.abstract_screenings.new(abstract_screening_params)
    if @abstract_screening.save
      flash[:notice] = 'Screening was successfully created'
      redirect_to project_abstract_screenings_path(@project)
    else
      flash[:now] = @abstract_screening.errors.full_messages.join(',')
      render :new
    end
  end

  def update_word_weight
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
    weight = params[:weight]
    word = params[:word].downcase
    id = params[:id]

    ww = WordWeight.find_by(id:) || WordWeight.find_or_initialize_by(word:, user: current_user,
                                                                     abstract_screening: @abstract_screening)
    if params[:destroy]
      ww.destroy
    else
      ww.update(weight:, word:)
    end
    render json: WordWeight.word_weights_object(current_user, @abstract_screening)
  end

  def citation_lifecycle_management
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @nav_buttons.push('lifecycle_management', 'my_projects')
    respond_to do |format|
      format.html
      format.json do
        @query = params[:query].present? ? params[:query] : '*'
        @order_by = params[:order_by]
        @sort = params[:sort].present? ? params[:sort] : nil
        @page = params[:page].present? ? params[:page].to_i : 1
        per_page = 100
        order = @order_by.present? ? { @order_by => @sort } : {}
        @citations_projects =
          CitationsProject
          .search(@query,
                  where: { project_id: @project.id },
                  limit: per_page, offset: per_page * (@page - 1), order:, load: false)
        @total_pages = (@citations_projects.total_count / per_page) + 1
      end
    end
  end

  def export_screening_data
    authorize(@project, policy_class: AbstractScreeningPolicy)
    respond_to do |format|
      format.xlsx do
        response.headers['Content-Disposition'] =
          "attachment; filename=\"screening_data_export_of_project_id_#{@project.id}.xlsx\""
      end
    end
  end

  def destroy
    @abstract_screening = AbstractScreening.find(params[:id])
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
    if @abstract_screening.destroy
      flash[:success] = 'The abstract screening was deleted.'
    else
      flash[:error] = 'The abstract screening could not be deleted.'
    end
    redirect_to project_abstract_screenings_path(@abstract_screening.project)
  end

  def edit
    @abstract_screening = AbstractScreening.find(params[:id])
    @project = @abstract_screening.project
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
  end

  def index
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @nav_buttons.push('abstract_screening', 'my_projects')
    @abstract_screenings =
      policy_scope(@project, policy_scope_class: AbstractScreeningPolicy::Scope)
      .order(id: :desc)
      .page(params[:page])
      .per(5)
  end

  def kpis
    authorize(@project, policy_class: AbstractScreeningPolicy)
  end

  def screen
    authorize(as = AbstractScreening.find(params[:abstract_screening_id]),
              policy_class: AbstractScreeningPolicy)
    respond_to do |format|
      format.json do
        asr =
          AbstractScreeningService.before_asr_id(as, params[:before_asr_id], current_user) ||
          AbstractScreeningResult.find_by(id: params[:asr_id])

        return render json: { asr_id: nil } if asr && asr.user != current_user

        asr ||= AbstractScreeningService.find_or_create_asr(as, current_user)
        render json: { asr_id: asr&.id }
      end
      format.html do
        render layout: 'abstrackr'
      end
    end
  end

  def show
    @abstract_screening = AbstractScreening.find(params[:id])
    @project = @abstract_screening.project
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
    @nav_buttons.push('abstract_screening', 'my_projects')

    respond_to do |format|
      format.html do
        flash.now[:notice] = 'There are no citations left to screen' if params[:screening_finished]
      end
      format.json do
        @query = params[:query].present? ? params[:query] : '*'
        @order_by = params[:order_by]
        @sort = params[:sort].present? ? params[:sort] : nil
        @page = params[:page].present? ? params[:page].to_i : 1
        per_page = 15
        order = @order_by.present? ? { @order_by => @sort } : { 'name' => 'desc' }
        where = { abstract_screening_id: @abstract_screening.id }
        where[:user_id] = current_user.id unless ProjectPolicy.new(current_user, @project).project_leader?
        @abstract_screening_results =
          AbstractScreeningResult
          .search(@query,
                  where:,
                  limit: per_page, offset: per_page * (@page - 1), order:, load: false)
        @total_pages = (@abstract_screening_results.total_count / per_page) + 1
      end
    end
  end

  def update
    @abstract_screening = AbstractScreening.find(params[:id])
    @project = @abstract_screening.project
    authorize(@abstract_screening.project, policy_class: AbstractScreeningPolicy)
    if @abstract_screening.update(abstract_screening_params)
      flash[:notice] = 'Screening was successfully updated'
      redirect_to project_abstract_screenings_path(@project)
    else
      flash[:now] = @abstract_screening.errors.full_messages.join(',')
      render :edit
    end
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
      :no_of_citations,
      :exclusive_users,
      user_ids: [],
      reason_ids: [],
      tag_ids: []
    )
    allow_new_tags(strong_params)
    allow_new_reasons(strong_params)
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

  def set_abstract_screening
    @abstract_screening = AbstractScreening.find(params[:abstract_screening_id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
