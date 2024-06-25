class ProjectsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:export]

  before_action :set_project, only: %i[
    citations_in_ris export_data show edit update destroy export
    export_assignments_and_mappings import_assignments_and_mappings simple_import
    import_csv import_pubmed import_endnote import_ris
    confirm_deletion dedupe_citations create_citation_screening_extraction_form
    create_full_text_screening_extraction_form machine_learning_results
  ]

  before_action :skip_authorization, only: %i[
    index edit show filter export new create
  ]
  before_action :skip_policy_scope, except: %i[
    index show edit update destroy filter export import_csv
    import_pubmed import_endnote import_ris
  ]

  # GET /projects
  # GET /projects.json
  def index
    @nav_buttons.push('my_projects')
    setup_instance_variables
  end

  # GET /projects/filter
  # GET /projects/filter.json
  def filter
    setup_instance_variables
    render 'index'
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    authorize(@project)
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  def edit
    authorize(@project)

    case params[:page]
    when 'key_questions'
      @nav_buttons.push('project_info_dropdown', 'key_questions', 'my_projects')
      render 'projects/edit/_manage_key_questions'
    when 'members_and_roles'
      @nav_buttons.push('project_info_dropdown', 'members_and_roles', 'my_projects')
      render 'projects/edit/_manage_projects_users'
    else
      @nav_buttons.push('project_info_dropdown', 'project_info', 'my_projects')
      render 'projects/edit/_manage_information'
    end
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)
    respond_to do |format|
      if save_without_sections_if_imported_files_params_exist @project
        format.html do
          redirect_to edit_project_path(@project),
                      notice: t('success')
        end
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    authorize(@project)

    respond_to do |format|
      format.html do
        if no_leader?
          flash[:alert] = 'You must have at least one leader in the project.'
          redirect_to(edit_project_path(@project, page: 'members_and_roles'))
        elsif @project.update(project_params)
          redirect_path = params.dig(:project, :redirect_path)
          if redirect_path.present?
            redirect_to(
              redirect_path,
              notice: t('success')
            )
          else
            redirect_back(
              fallback_location: edit_project_path(@project, page: 'info'),
              notice: t('success')
            )
          end
        else
          flash[:alert] = @project.errors.full_messages.join(' - ')
          redirect_path = params.dig(:project, :redirect_path)
          if redirect_path.present?
            redirect_to(
              redirect_path,
              error: t('failure')
            )
          else
            redirect_back(
              fallback_location: edit_project_path(@project, page: 'info'),
              error: t('failure')
            )
          end
        end
      end

      format.json do
        if @project.update(project_params)
          render json: { success: true, project: @project }, status: :ok
        else
          render json: { success: false, errors: @project.errors }, status: :unprocessable_entity
        end
      end

      format.js do
        if @project.update(project_params)
          render :show, status: :ok, location: @project
        else
          render json: @project.errors, status: :unprocessable_entity
        end
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    authorize(@project)

    @project.destroy
    flash[:info] = t('.removed')
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json {}
    end
  end

  def export
    authenticate_user! unless export_type_name_params == '.xlsx' || export_type_name_params == '.xlsx legacy'

    email = params[:email]
    authenticate_user! unless current_user || ((email =~ URI::MailTo::EMAIL_REGEXP) == 0)

    if @project.public? || authorize(@project)
      if @project.extraction_forms_projects.first.extraction_forms_project_type_id != 1
        SimpleExportJob.set(wait: 1.minute).perform_later(
          current_user ? current_user.email : email, @project.id, export_type_name_params
        )
      else
        AdvancedExportJob.set(wait: 1.minute).perform_later(
          current_user ? current_user.email : email, @project.id
        )
      end
      Event.create(
        sent: current_user ? current_user.email : email,
        action: 'Export',
        resource: @project.class.to_s,
        resource_id: @project.id,
        notes: export_type_name_params
      )

      redirect_back(
        fallback_location: project_path(@project),
        notice: "Export request submitted for project '#{@project.name}'. You will be notified by email of its completion.",
        status: 303
      )
    else
      redirect_back(
        fallback_location: project_path(@project),
        flash: { error: 'You are not authorized to export this project.' },
        status: 303
      )
    end
  end

  def export_assignments_and_mappings
    authorize(@project)
    assignment_list = ExportAssignmentsAndMappingsJob.perform_now(@project.id)
    file_name = "Assignments and Mappings Template - Project ID #{@project.id}.xlsx"
    send_data(assignment_list.to_stream.read, filename: file_name)
  end

  def import_assignments_and_mappings
    authorize(@project)
    file = import_assignments_and_mappings_params[:imported_file][:content]
    unless _check_valid_file_extension(file)
      @import = Struct.new(:errors).new(nil)
      @import.errors = 'Invalid file format'
      respond_to do |format|
        format.json { render json: @import.errors.to_json, status: :unprocessable_entity }
      end
      return
    end

    # Verify that we are importing Assignments and Mappings.
    import_type_id = import_assignments_and_mappings_params[:import_type_id].to_i
    unless import_type_id.eql?(ImportType.find_by(name: ImportType::ASSIGNMENTS_MAPPINGS).id)
      @import = Struct.new(:errors).new(nil)
      @import.errors = 'Invalid Import Type -- you are not importing user Assignments and Mappings.'
      respond_to do |format|
        format.json { render json: @import.errors.to_json, status: :unprocessable_entity }
      end
      return
    end

    projects_user_id = import_assignments_and_mappings_params[:projects_user_id].to_i
    file_type_id = import_assignments_and_mappings_params[:imported_file][:file_type_id].to_i

    import_hash = {
      import_type_id:,
      projects_user_id:,
      imported_files_attributes: [
        {
          content: file,
          file_type_id:
        }
      ]
    }

    @import = Import.new(import_hash)
    authorize(@import.project, policy_class: ImportPolicy)

    respond_to do |format|
      if @import.save
        @import.start_import_job
        flash[:success] =
          "Import request of Assignments and Mappings submitted for project '#{@project.name}'. You will be notified by email of its completion."
        format.json { render json: @import, status: :ok }
        format.html { redirect_to project_imports_path(@project) }
      else
        flash[:error] =
          "Error encountered. Unable to process import request of Assignments and Mappings submitted for project '#{@project.name}'."
        format.json { render json: @import.errors, status: :unprocessable_entity }
        format.html { redirect_to project_imports_path(@project) }
      end
    end
  end

  def simple_import
    authorize(@project)
    file = import_assignments_and_mappings_params[:imported_file][:content]
    unless _check_valid_file_extension(file)
      @import = Struct.new(:errors).new(nil)
      @import.errors = 'Invalid file format'
      respond_to do |format|
        format.json { render json: @import.errors.to_json, status: :unprocessable_entity }
      end
      return
    end

    import_type_id = import_assignments_and_mappings_params[:import_type_id].to_i
    unless import_type_id.eql?(ImportType.find_by(name: ImportType::PROJECT).id)
      @import = Struct.new(:errors).new(nil)
      @import.errors = 'Invalid Import Type -- you are not importing a project.'
      respond_to do |format|
        format.json { render json: @import.errors.to_json, status: :unprocessable_entity }
      end
      return
    end

    projects_user_id = import_assignments_and_mappings_params[:projects_user_id].to_i
    file_type_id = import_assignments_and_mappings_params[:imported_file][:file_type_id].to_i
    simple_import_strategy = import_assignments_and_mappings_params[:simple_import_strategy]

    import_hash = {
      import_type_id:,
      projects_user_id:,
      simple_import_strategy:,
      imported_files_attributes: [
        {
          content: file,
          file_type_id:
        }
      ]
    }

    @import = Import.new(import_hash)
    authorize(@import.project, policy_class: ImportPolicy)

    respond_to do |format|
      if @import.already_queued?
        flash[:error] =
          'This import is already enqueued or in progress. You will be notified by email of its completion.'
        format.json do
          render json: {
            message: 'This import is already enqueued or in progress. You will be notified by email of its completion.'
          }, status: :unprocessable_entity
        end
        format.html { redirect_to project_imports_path(@project) }
      elsif @import.save
        @import.start_import_job
        flash[:success] =
          "Import request of project '#{@project.name}'. You will be notified by email of its completion."
        format.json { render json: @import, status: :ok }
        format.html { redirect_to project_imports_path(@project) }
      else
        flash[:error] = "Error encountered. Unable to process import request of project '#{@project.name}'."
        format.json { render json: @import.errors, status: :unprocessable_entity }
        format.html { redirect_to project_imports_path(@project) }
      end
    end
  end

  def import_ris
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    RisImportJob.set(wait: 1.minute).perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] =
      "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."

    redirect_to(project_citations_path(@project), status: 303)
  end

  def import_csv
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    CsvImportJob.set(wait: 1.minute).perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] =
      "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."

    redirect_to(project_citations_path(@project), status: 303)
  end

  def import_pubmed
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    PubmedImportJob.set(wait: 1.minute).perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] =
      "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."
    # @project.import_citations_from_pubmed( citation_import_params[:citation_file] )

    redirect_to(project_citations_path(@project), status: 303)
  end

  def import_endnote
    authorize(@project)
    @project.citation_files.attach(citation_import_params[:citation_files])
    EnlImportJob.set(wait: 1.minute).perform_later(current_user.id, @project.id, @project.citation_files.last.id)
    flash[:success] =
      "Import request submitted for project '#{@project.name}'. You will be notified by email of its completion."

    redirect_to(project_citations_path(@project), status: 303)
  end

  def dedupe_citations
    authorize(@project)
    DedupeCitationsJob.set(wait: 1.minute).perform_later(@project.id)
    # @project.dedupe_citations
    flash[:success] = 'Request to deduplicate citations has been received. Please come back later.'

    redirect_to(project_citations_path(@project), status: 303)
  end

  def create_citation_screening_extraction_form
    authorize(@project)
    @project.extraction_forms_projects.find_or_create_by(
      extraction_forms_project_type: ExtractionFormsProjectType.find_or_create_by(name: 'Citation Screening Extraction Form'),
      extraction_form: ExtractionForm.find_or_create_by(name: 'ef2')
    )
    flash[:success] = 'Success.'

    redirect_to(edit_project_path(@project, anchor: 'panel-citation-screening-extraction-form'), notice: t('success'),
                                                                                                 status: 303)
  end

  def create_full_text_screening_extraction_form
    authorize(@project)
    @project.extraction_forms_projects.find_or_create_by(
      extraction_forms_project_type: ExtractionFormsProjectType.find_or_create_by(name: 'Full Text Screening Extraction Form'),
      extraction_form: ExtractionForm.find_or_create_by(name: 'ef3')
    )
    flash[:success] = 'Success.'
  end

  def machine_learning_results
    authorize(@project)
    @scores = MachineLearningStatisticService.get_unscreened_prediction_scores(@project.id)
    @labels_with_scores = MachineLearningStatisticService.get_labels_with_scores(@project.id)
    @latest_model_time = MachineLearningStatisticService.latest_model_time(@project.id)
    @rejection_counter = MachineLearningStatisticService.count_recent_consecutive_rejects(@project.id)
    @estimated_coverage = MachineLearningStatisticService.get_estimated_coverage_to_total_size(@project.id)
    @total_citation_number = @project.citations.count()
    @unscreened_citation_number = Citation
                                  .joins(:citations_projects)
                                  .where(citations_projects: { project_id: @project.id })
                                  .includes(citations_projects: :abstract_screening_results)
                                  .where(abstract_screening_results: { id: nil })
                                  .count
    latest_ml_model = MlModel.joins(:projects)
                             .where("projects.id = ?", @project.id)
                             .order(created_at: :desc)
                             .limit(1)
                             .first
    if latest_ml_model
      @top_unscreened_citations = @project.citations
                                          .joins(citations_projects: :ml_predictions)
                                          .where(citations_projects: { project_id: @project.id })
                                          .where.not(citations_projects: { id: AbstractScreeningResult.select(:citations_project_id) })
                                          .where.not(citations_projects: { id: ScreeningQualification.select(:citations_project_id) })
                                          .where(ml_predictions: { ml_model_id: latest_ml_model.id })
                                          .select('citations.*', 'ml_predictions.score', 'citations_projects.id AS citations_project_id')
                                          .order('ml_predictions.score DESC')
                                          .limit(20)

      citations_project_ids = @top_unscreened_citations.map { |item| item.citations_project_id }
      scores_map = @top_unscreened_citations.each_with_object({}) do |item, map|
        map[item.citations_project_id] = item.score
      end

      @searched_top_unscreened_citations = CitationsProject.search('*', where: { citations_project_id: citations_project_ids }, load: false)
      @searched_top_unscreened_citations.each do |result|
        result['ml_score'] = scores_map[result.citations_project_id]
      end
      @searched_top_unscreened_citations
    else
      @searched_top_unscreened_citations = []
    end
    @percentage_unscreened = (@unscreened_citation_number.to_f / @total_citation_number) * 100
    @percentage_unscreened = @percentage_unscreened.round(1)
    @untrained_citation_number = MachineLearningDataSupplyingService.get_labeled_abstract_since_last_train(@project.id).size
  end

  def citations_in_ris
    authorize @project
    citation_ids = params[:project][:citation]
    respond_to do |format|
      format.json do
        render status: 204 unless citation_ids.all?{ |x| x.is_a? Integer }
        cres = CitationsRisExportService.new('RIS', @project.id, citation_ids)
        @payload = cres.export
        json_response = {
          payload: @payload
        }
        render json: json_response
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project
               .includes(publishing: :approval)
               .includes(projects_users: [user: :profile])
               .find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def project_params
    if action_name != 'create'
      params.require(:project).permit(policy(@project).permitted_attributes)
    else
      params.require(:project).permit(*ProjectPolicy::FULL_PARAMS)
    end
  end

  def import_params
    params.require(:import).permit(imported_files: [])
  end

  def save_without_sections_if_imported_files_params_exist(project)
    @project = project
    if project_params[:projects_users_attributes].present?
      project.create_empty = true

      return false unless project.save

      if project.imported_files.present?
        project.imports.first.start_import_job
        flash[:success] =
          "Import request submitted for project '#{project.name}'. You will be notified by email of its completion."
      end

      return true

    else
      # Setting default KQ.
      project.key_questions << KeyQuestion.first unless project.key_questions.present?

    end

    project.save
  end

  # def import_params
  #  params.require(:project)
  #      .permit(
  # end

  # def distiller_params
  #   # what kind of files do we want to import?
  #   params.require(:project).permit(:citation_file, :design_file, :arms_file, :outcomes_file, :bc_file, :rob_file)
  # end

  # def json_params
  #   params.require(:project).permit(:json_file)
  # end

  def citation_import_params
    # what kind of files do we want to import?
    params.require(:project).permit(citation_files: [])
  end

  def export_type_name_params
    params.require(:export_type_name)
  end

  def import_assignments_and_mappings_params
    params.require(:import).permit(:projects_user_id, :import_type_id, :simple_import_strategy,
                                   imported_file: %i[file_type_id content])
  end

  # def import_project_from_distiller(project)
  #   DistillerImportJob.set(wait: 1.minute).perform_later(current_user.id, project.id)
  #   flash[:success] = "Import request submitted for project '#{ project.name }'. You will be notified by email of its completion."
  # end

  def setup_instance_variables
    @query = params.dig(:project, :q)
    @order = params[:o] || 'updated-at'
    @project_status = params.dig(:project, :project_status) || params[:project_status]
    @params = { project: { q: @query }, project_status: @project_status }

    if @project_status.blank?
      @projects = policy_scope(Project)
                  .includes(publishing: [{ user: :profile }, approval: [{ user: :profile }]])
                  .by_name_description_and_query(@query)
                  .page(params[:page])

      # Introduced projects_paginate_per value in user.profile
      # We scope on that value if it exists, otherwise keep default
      # paginate per set in model/project.rb
      if current_user.profile.projects_paginate_per.present?
        @projects = rescope(
          @projects,
          params[:page],
          current_user.profile.projects_paginate_per
        )
      end

      @projects = @projects.order(updated_at: :desc) if params[:o].nil? || params[:o] == 'updated-at'
      @projects = @projects.order(created_at: :desc) if params[:o] == 'created-at'

      project_ids = @projects.pluck(:id)
      @projects_key_questions_project_counts = KeyQuestionsProject
                                               .where(project_id: project_ids)
                                               .group(:project_id)
                                               .count

      @projects_citations_project_counts = CitationsProject
                                           .where(project_id: project_ids)
                                           .group(:project_id)
                                           .count

      @projects_projects_user_counts = ProjectsUser
                                       .where(project_id: project_ids)
                                       .group(:project_id)
                                       .count

      @projects_extraction_counts_wo_consolidated = Extraction
                                                    .where(consolidated: false)
                                                    .where(project_id: project_ids)
                                                    .group(:project_id)
                                                    .count

      @projects_extraction_counts_w_consolidated = Extraction
                                                   .where(consolidated: true)
                                                   .where(project_id: project_ids)
                                                   .group(:project_id)
                                                   .count

      @projects_extraction_counts = Extraction
                                    .where(project_id: project_ids)
                                    .group(:project_id)
                                    .count

      @projects_extraction_forms_project_ids = ExtractionFormsProject
                                               .where(project_id: project_ids)
                                               .group_by(&:project_id)

      @sd_meta_data_counts = SdMetaDatum
                             .where(project_id: project_ids)
                             .group_by(&:project_id)
                             .count

      @projects_extracted_citations_counts = CitationsProject
                                             .joins(:extractions)
                                             .distinct
                                             .where(project_id: project_ids)
                                             .group(:project_id)
                                             .count

    elsif @project_status == 'draft'
      @projects = policy_scope(Project)
                  .draft
                  .includes(publishing: [{ user: :profile }, approval: [{ user: :profile }]])
                  .by_name_description_and_query(@query)
                  .page(params[:page])

      # Introduced projects_paginate_per value in user.profile
      # We scope on that value if it exists, otherwise keep default
      # paginate per set in model/project.rb
      if current_user.profile.projects_paginate_per.present?
        @projects = rescope(
          @projects,
          params[:page],
          current_user.profile.projects_paginate_per
        )
      end

      @projects = @projects.order(updated_at: :desc) if params[:o].nil? || params[:o] == 'updated-at'
      @projects = @projects.order(created_at: :desc) if params[:o] == 'created-at'

      project_ids = @projects.pluck(:id)
      @projects_key_questions_project_counts = KeyQuestionsProject
                                               .where(project_id: project_ids)
                                               .group(:project_id)
                                               .count

      @projects_citations_project_counts = CitationsProject
                                           .where(project_id: project_ids)
                                           .group(:project_id)
                                           .count

      @projects_projects_user_counts = ProjectsUser
                                       .where(project_id: project_ids)
                                       .group(:project_id)
                                       .count

      @projects_extraction_counts_wo_consolidated = Extraction
                                                    .where(consolidated: false)
                                                    .where(project_id: project_ids)
                                                    .group(:project_id)
                                                    .count

      @projects_extraction_counts_w_consolidated = Extraction
                                                   .where(consolidated: true)
                                                   .where(project_id: project_ids)
                                                   .group(:project_id)
                                                   .count

      @projects_extraction_counts = Extraction
                                    .where(project_id: project_ids)
                                    .group(:project_id)
                                    .count

      @projects_extraction_forms_project_ids = ExtractionFormsProject
                                               .where(project_id: project_ids)
                                               .group_by(&:project_id)

      @sd_meta_data_counts = SdMetaDatum
                             .where(project_id: project_ids)
                             .group_by(&:project_id)
                             .count

      @projects_extracted_citations_counts = CitationsProject
                                             .joins(:extractions)
                                             .distinct
                                             .where(project_id: project_ids)
                                             .group(:project_id)
                                             .count

    elsif @project_status == 'pending'
      @unapproved_publishings = Publishing
                                .includes([:publishable])
                                .joins('left join projects ON publishings.publishable_id = projects.id')
                                .joins('left join sd_meta_data ON sd_meta_data.id = publishings.publishable_id')
                                .where('projects.name LIKE ? OR sd_meta_data.report_title LIKE ?', "%#{@query}%", "%#{@query}%")
                                .unapproved
                                .page(params[:page])
      if params[:o].nil? || params[:o] == 'updated-at'
        @unapproved_publishings = @unapproved_publishings.order(updated_at: :desc)
      end
      @unapproved_publishings = @unapproved_publishings.order(created_at: :desc) if params[:o] == 'created-at'

    elsif @project_status == 'published'
      @approved_publishings = Publishing
                              .includes([:publishable])
                              .preload(:approval)
                              .joins('left join projects ON publishings.publishable_id = projects.id')
                              .joins('left join sd_meta_data ON sd_meta_data.id = publishings.publishable_id')
                              .joins('INNER JOIN `projects_users` ON `projects`.`id` = `projects_users`.`project_id`')
                              .where('projects.name LIKE ? OR sd_meta_data.report_title LIKE ?', "%#{@query}%", "%#{@query}%")
                              .approved
                              .page(params[:page])
      unless current_user.admin?
        @approved_publishings = @approved_publishings
                                .where(
                                  '`projects_users`.`user_id` = ?',
                                  current_user.id.to_s
                                )
      end

      if params[:o].nil? || params[:o] == 'updated-at'
        @approved_publishings = @approved_publishings.order(updated_at: :desc)
      end
      @approved_publishings = @approved_publishings.order(created_at: :desc) if params[:o] == 'created-at'
    end
  end

  def no_leader?
    project_params[:projects_users_attributes] &&
      project_params[:projects_users_attributes].values.any? { |key| key[:permissions] } &&
      project_params[:projects_users_attributes].values.none? do |pua|
        pua[:permissions].to_i.to_s(2)[-1] == '1'
      end
  end

  def _check_valid_file_extension(file)
    extension = file.original_filename.match(/(\.[a-z]+$)/i)[0]
    ['.xlsx'].include?(extension)
  end

  def rescope(projects, page, per)
    projects.except(:limit, :offset).page(page).per(per)
  end
end
