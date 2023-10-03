class FulltextScreeningsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :set_project, only: %i[index new create]
  before_action :set_fulltext_screening, only: %i[screen]
  after_action :verify_authorized

  def new
    @fulltext_screening = @project.fulltext_screenings.new
    authorize(@fulltext_screening)
  end

  def create
    @fulltext_screening =
      @project.fulltext_screenings.new(fulltext_screening_params)
    authorize(@fulltext_screening)
    if @fulltext_screening.save
      flash[:notice] = 'Screening was successfully created'
      redirect_to(project_fulltext_screenings_path(@project), status: 303)
    else
      flash[:now] = @fulltext_screening.errors.full_messages.join(',')
      render :new
    end
  end

  def destroy
    @fulltext_screening = FulltextScreening.find(params[:id])
    authorize(@fulltext_screening)
    if @fulltext_screening.destroy
      flash[:success] = 'The fulltext screening was deleted.'
    else
      flash[:error] = 'The screening could not be deleted.'
    end
    redirect_to(project_fulltext_screenings_path(@fulltext_screening.project), status: 303)
  end

  def edit
    @fulltext_screening = FulltextScreening.find(params[:id])
    @project = @fulltext_screening.project
    authorize(@fulltext_screening)
  end

  def index
    authorize(@project, policy_class: FulltextScreeningPolicy)
    @nav_buttons.push('fulltext_screening', 'my_projects')
    @fulltext_screenings =
      policy_scope(@project, policy_scope_class: FulltextScreeningPolicy::Scope)
      .order(id: :desc)
      .page(params[:page])
      .per(5)
  end

  def screen
    fs = FulltextScreening.find(params[:fulltext_screening_id])
    authorize(fs)
    respond_to do |format|
      format.json do
        fsr = if params[:fsr_id]
                FulltextScreeningResult.find_by(id: params[:fsr_id])
              else
                FulltextScreeningService.find_or_create_unprivileged_sr(fs, current_user)
              end

        return render json: { fsr_id: nil } if fsr && fsr.user != current_user

        render json: { fsr_id: fsr&.id }
      end
      format.html do
        render layout: 'abstrackr'
      end
    end
  end

  def show
    @fulltext_screening = FulltextScreening.find(params[:id])
    @project = @fulltext_screening.project
    authorize(@fulltext_screening)
    @nav_buttons.push('fulltext_screening', 'my_projects')

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
        where = { fulltext_screening_id: @fulltext_screening.id }
        where[:user_id] = current_user.id unless ProjectPolicy.new(current_user, @project).project_leader?
        @fulltext_screening_results =
          FulltextScreeningResult
          .search(@query,
                  where:,
                  limit: per_page, offset: per_page * (@page - 1), order:, load: false)
        @total_pages = (@fulltext_screening_results.total_count / per_page) + 1
      end
    end
  end

  def update
    @fulltext_screening = FulltextScreening.find(params[:id])
    @project = @fulltext_screening.project
    authorize(@fulltext_screening)
    if @fulltext_screening.update(fulltext_screening_params)
      flash[:notice] = 'Screening was successfully updated'
      redirect_to(project_fulltext_screenings_path(@project), status: 303)
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

  def set_fulltext_screening
    @fulltext_screening = FulltextScreening.find(params[:fulltext_screening_id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end
end
