class AbstractScreeningsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update_word_weight kpis]

  before_action :set_project,
                only: %i[index new create citation_lifecycle_management export_screening_data kpis work_selection]
  before_action :set_abstract_screening, only: %i[update_word_weight screen]
  after_action :verify_authorized

  def new
    @abstract_screening = @project.abstract_screenings.new(abstract_screening_type: 'double-perpetual')
    authorize(@abstract_screening)
  end

  def create
    @abstract_screening =
      @project.abstract_screenings.new(abstract_screening_params)
    authorize(@abstract_screening)
    if @abstract_screening.save
      flash[:notice] = 'Screening was successfully created'
      redirect_to(project_abstract_screenings_path(@project), status: 303)
    else
      flash[:now] = @abstract_screening.errors.full_messages.join(',')
      render :new
    end
  end

  def update_word_weight
    authorize(@abstract_screening)
    weight = params[:weight]
    word = params[:word]
    group_id = params[:group_id]
    color = params[:color]
    group_name = params[:group_name]
    case_sensitive = params[:case_sensitive]

    word_group = nil
    if group_id.present?
      word_group = WordGroup.find_by(id: group_id, user: current_user, abstract_screening: @abstract_screening)
      unless word_group
        render json: { error: 'WordGroup not found' }, status: :not_found
        return
      end

      if params[:destroy_wg].to_s == 'true'
        word_group.destroy
        render json: WordGroup.word_weights_object(current_user, @abstract_screening)
        return
      elsif group_name.present? || color.present? || !case_sensitive.nil?
        word_group.update(
          name: group_name.presence || word_group.name,
          color: color.presence || word_group.color,
          case_sensitive: case_sensitive.nil? ? word_group.case_sensitive : case_sensitive,
        )
      end
    elsif color.present? && group_name.present? && params[:destroy_wg].to_s != 'true'
      word_group = WordGroup.create!(color:, name: group_name, user: current_user, abstract_screening: @abstract_screening)
    elsif params[:destroy_wg].to_s != 'true'
      render json: { error: 'Missing color or group name for new WordGroup or invalid destroy_wg flag' },
             status: :bad_request
      return
    end

    if word.present? && word_group
      ww = WordWeight.find_by(word: word, user: current_user, abstract_screening: @abstract_screening)
      if ww.nil?
        if params[:id].present?
          ww = WordWeight.find_by(id: params[:id])
          ww.update(word: word, word_group: word_group)
        else
          WordWeight.create!(word: word, weight: weight, user: current_user, abstract_screening: @abstract_screening, word_group: word_group)
        end
      elsif params[:id].present? && ww.id == params[:id]
        if params[:destroy_ww].to_s == 'true'
          ww.destroy
        end
      end
    end

    render json: WordGroup.word_weights_object(current_user, @abstract_screening)
  end

  def citation_lifecycle_management
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @nav_buttons.push('project_info_dropdown', 'lifecycle_management', 'my_projects')
    respond_to do |format|
      format.html
      format.json do
        @query = params[:query].present? ? params[:query] : '*'
        @order_by = params[:order_by]
        @sort = params[:sort].present? ? params[:sort] : nil
        @page = params[:page].present? ? params[:page].to_i : 1
        per_page = 100
        order = @order_by.present? ? { @order_by => @sort } : {}
        where_hash = { project_id: @project.id }
        title_terms = []
        author_terms = []

        # Parse field-specific queries (e.g., status:asu, title:keyword)
        if @query.match(/(status:([\w\d]+))/)
          query_match, status_value = @query.match(/(status:([\w\d]+))/).captures
          where_hash[:screening_status] = status_value
          @query.slice!(query_match)
        end

        # Parse title-specific queries (e.g., title:assay title:pcr)
        while @query.match(/(title:([\w\d]+))/)
          query_match, title_term = @query.match(/(title:([\w\d]+))/).captures
          title_terms << title_term
          @query.slice!(query_match)
        end

        # Parse author-specific queries (e.g., author:smith author:jones)
        while @query.match(/(author:([\w\d]+))/)
          query_match, author_term = @query.match(/(author:([\w\d]+))/).captures
          author_terms << author_term
          @query.slice!(query_match)
        end

        # Clean up query after slicing
        @query = @query.strip

        # Build search options
        search_options = {
          where: where_hash,
          limit: per_page,
          offset: per_page * (@page - 1),
          order: order,
          load: false
        }

        # Handle field-specific searches
        if title_terms.any? && author_terms.any?
          # Both title and author searches
          title_query = title_terms.join(' ')
          author_query = author_terms.join(' ')
          @query = "#{title_query} #{author_query}"
          search_options[:fields] = ['name', 'author_map_string']
        elsif title_terms.any?
          # Title-only search
          @query = title_terms.join(' ')
          search_options[:fields] = ['name']
        elsif author_terms.any?
          # Author-only search
          @query = author_terms.join(' ')
          search_options[:fields] = ['author_map_string']
        elsif @query.blank?
          @query = '*'
        end

        @citations_projects = CitationsProject.search(
          @query,
          **search_options
        )
        @total_pages = (@citations_projects.total_count / per_page) + 1
      end
    end
  end

  def export_screening_data
    authorize(@project, policy_class: AbstractScreeningPolicy)
    ScreeningDataExportJob.set(wait: 5.second).perform_later(current_user.email, @project.id)
    Event.create(
      sent: current_user.email,
      action: 'Export Screening Labels',
      resource: @project.class.to_s,
      resource_id: @project.id,
      notes: ''
    )
    redirect_back(
      fallback_location: project_path(@project),
      notice: 'Your export is being processed.  You will be notified via email when it is completed.',
      status: 303
    )
  end

  def destroy
    respond_to do |format|
      format.html do
        @abstract_screening = AbstractScreening.find(params[:id])
        authorize(@abstract_screening)
        if @abstract_screening.destroy
          flash[:success] = 'The abstract screening was deleted.'
        else
          flash[:error] = 'The abstract screening could not be deleted.'
        end
        redirect_to(project_abstract_screenings_path(@abstract_screening.project))
      end
    end
  end

  def edit
    @abstract_screening = AbstractScreening.find(params[:id])
    @project = @abstract_screening.project
    authorize(@abstract_screening)
  end

  def index
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @nav_buttons.push('screening_dropdown', 'abstract_screening', 'my_projects')
    @abstract_screenings =
      policy_scope(@project, policy_scope_class: AbstractScreeningPolicy::Scope)
      .order(id: :desc)
      .page(params[:page])
      .per(5)
  end

  def work_selection
    @nav_buttons.push('screening_dropdown', 'abstract_screening', 'my_projects')
    authorize(@project, policy_class: AbstractScreeningPolicy)
  end

  def kpis
    authorize(@project, policy_class: AbstractScreeningPolicy)
  end

  def screen
    authorize(@abstract_screening)
    respond_to do |format|
      format.json do
        asr = if params[:resolution_mode]
                AbstractScreeningService.find_asr_to_be_resolved(@abstract_screening, current_user)
              elsif params[:asr_id]
                AbstractScreeningResult.find_by(id: params[:asr_id])
              else
                AbstractScreeningService.find_or_create_unprivileged_sr(@abstract_screening, current_user)
              end

        return render json: { asr_id: nil } unless asr && (asr.user == current_user ||
                                                   (asr.privileged && ProjectsUser.find_by(
                                                     project: asr.project, user: current_user
                                                   ).project_consolidator?) ||
                                                    ProjectsUser.find_by(
                                                      project: asr.project, user: current_user
                                                    ).project_leader?)

        render json: { asr_id: asr&.id }
      end
      format.html do
        render layout: 'abstrackr'
      end
    end
  end

  def show
    @abstract_screening = AbstractScreening.includes(abstract_screening_results: :user).find(params[:id])
    @project = @abstract_screening.project
    authorize(@abstract_screening)
    @projects_user = ProjectsUser.find_by(user: current_user, project: @project)
    @nav_buttons.push('screening', 'my_projects')

    respond_to do |format|
      format.html do
        flash.now[:notice] = 'There are no citations left to screen' if params[:screening_finished]
      end
      format.json do
        @query = params[:query].to_s
        @order_by = params[:order_by]
        @sort = params[:sort].present? ? params[:sort] : nil
        @page = params[:page].present? ? params[:page].to_i : 1
        per_page = 15
        order = @order_by.present? ? { @order_by => @sort } : {}
        where_hash = { abstract_screening_id: @abstract_screening.id }
        where_hash[:user_id] = current_user.id unless ProjectPolicy.new(current_user, @project).project_consolidator?

        # Collect all field-specific terms
        field_terms = {}
        # Map user-facing field names to actual database fields
        field_mapping = {
          'title' => 'name',
          'accession_number' => 'accession_number_alts',
          'author' => 'author_map_string',
          'year' => 'year',
          'user' => 'user',
          'label' => 'label',
          'privileged' => 'privileged',
          'reason' => 'reasons',
          'tag' => 'tags',
          'note' => 'notes'
        }

        field_mapping.keys.each do |search_field|
          field_terms[search_field] = []

          # Collect all occurrences of this field
          while @query.match(/(#{search_field}:(-?[\w\d]+))/)
            query_match, keyword = @query.match(/(#{search_field}:(-?[\w\d]+))/).captures
            field_terms[search_field] << keyword
            @query.slice!(query_match)
          end
        end

        # Separate text search fields from exact match fields
        text_search_fields = []
        text_search_query_parts = []

        field_terms.each do |search_field, terms|
          next if terms.empty?

          # Map to actual database field
          db_field = field_mapping[search_field]

          case search_field
          when 'privileged'
            where_hash[db_field] = terms.first == 'true'
          when 'label'
            where_hash[db_field] = terms.first == 'null' ? nil : terms.first
          when 'title', 'author', 'accession_number', 'year', 'user', 'reason', 'tag', 'note'
            # Text fields - use fields parameter for better matching
            text_search_fields << db_field
            text_search_query_parts << terms.join(' ')
          else
            # Fallback for any other fields
            where_hash[db_field] = terms.join(' ')
          end
        end

        @query = @query.strip

        # Build search options
        search_options = {
          where: where_hash,
          limit: per_page,
          offset: per_page * (@page - 1),
          order: order,
          load: false
        }

        # If we have text search fields, use fields parameter
        if text_search_fields.any?
          search_options[:fields] = text_search_fields
          @query = text_search_query_parts.join(' ') if text_search_query_parts.any?
        end

        @query = '*' if @query.blank?

        @abstract_screening_results =
          AbstractScreeningResult.search(@query, **search_options)
        @total_pages = (@abstract_screening_results.total_count / per_page) + 1
      end
    end
  end

  def update
    @abstract_screening = AbstractScreening.find(params[:id])
    @project = @abstract_screening.project
    authorize(@abstract_screening)
    if @abstract_screening.update(abstract_screening_params)
      flash[:notice] = 'Screening was successfully updated'
      redirect_to(project_abstract_screenings_path(@project), status: 303)
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
      :yes_form_required,
      :no_form_required,
      :maybe_form_required,
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
