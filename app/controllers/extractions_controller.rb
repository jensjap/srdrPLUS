class ExtractionsController < ApplicationController
  include ExtractionsControllerHelpers

  before_action :set_project,
                only: %i[index new create comparison_tool compare consolidate edit_type1_across_extractions]
  before_action :set_extraction, only: %i[show edit update destroy work update_kqp_selections]
  before_action :set_extractions, only: %i[consolidate]
  before_action :ensure_extraction_form_structure, only: %i[consolidate work]
  before_action :set_eefps_by_efps_dict, only: [:work]

  before_action :skip_policy_scope, except: %i[compare consolidate edit_type1_across_extractions]
  before_action :skip_authorization, only: %i[index show]

  # GET /projects/1/extractions
  # GET /projects/1/extractions.json
  def index
    @nav_buttons.push('extractions', 'my_projects')
    @extractions = @project
                   .extractions
                   .unconsolidated
                   .includes([
                               { citations_project: { citation: [:journal, :authors,
                                                                 { authors_citations: :ordering }] } },
                               { extractions_extraction_forms_projects_sections: [:status] },
                               { projects_users_role: [{ projects_user: { user: :profile } }, :role] }
                             ])
    @extractions = ExtractionDecorator.decorate_collection(@extractions)

    if @project.leaders.include? current_user
      @projects_users_roles = ProjectsUsersRole
                              .includes([{ projects_user: { user: :profile } }, :role])
                              .where(projects_users: { project: @project })
      @projects_users_roles = @projects_users_roles.sort_by { |pur| pur.role_id }.uniq { |pur| pur.user }
    end
  end

  def reassign_extraction
    @nav_buttons.push('extractions', 'my_projects')
    @extraction = Extraction.find(params[:id])
  end

  # GET /extractions/1
  # GET /extractions/1.json
  def show; end

  # GET /extractions/new
  def new
    @extraction           = @project.extractions.new(citations_project: CitationsProject.new(project: @project))
    @citations_projects   = @project.citations_projects
    @citations            = @project.citations
    @projects_users_roles = ProjectsUsersRole.joins(:projects_user).where(projects_users: { project: @project })
    unless policy(@project).assign_extraction_to_any_user?
      @projects_users_roles = @projects_users_roles.where(projects_users: { user: current_user })
    end
    @current_projects_users_role = ProjectsUsersRole.joins(:projects_user).where(projects_users: { user: current_user,
                                                                                                   project: @project }).order(role_id: :asc).first
    @existing_pmids = @project.extractions.map(&:citation).compact.map(&:pmid).join('//$$//')

    authorize(@extraction.project, policy_class: ExtractionPolicy)
  end

  # GET /extractions/1/edit
  def edit
    @citations_projects   = @extraction.project.citations_projects
    @projects_users_roles = ProjectsUsersRole.joins(:projects_user).where(projects_users: { project: @extraction.project })

    authorize(@extraction.project, policy_class: ExtractionPolicy)
  end

  # POST /extractions
  # POST /extractions.json
  def create
    authorize(@project, policy_class: ExtractionPolicy)

    succeeded = []
    skipped = []
    failed = []
    extractions = []
    projects_users_role = ProjectsUsersRole.find(params['extraction']['projects_users_role_id'])
    params['extraction']['citation'].delete_if { |i| i == '' }.map(&:to_i).each do |citation_id|
      citations_project = CitationsProject.find_by(citation_id:, project: @project)
      extraction = Extraction.find_by(project: @project, citations_project:, projects_users_role:)
      if params['extraction']['noDuplicates'] && extraction
        skipped << extraction
      else
        extractions << @project.extractions.build(
          citations_project:,
          projects_users_role:
        )
      end
    end

    extractions.each do |extraction|
      if extraction.save
        succeeded << extraction
      else
        failed << extraction
      end
    end

    respond_to do |format|
      format.html do
        if extractions.length.zero?
          redirect_to project_extractions_url(@project), notice: 'Please select a citation.'
        elsif extractions.count != succeeded.count
          failed_citation_names = failed.map { |extraction| extraction.citation.name }.join("\n\n")
          error = "The following citations were unsuccessfully assigned: #{failed_citation_names}"
          redirect_to project_extractions_url(@project), error:
        elsif extractions.count == 1 && extractions.count == succeeded.count
          redirect_to work_extraction_path(succeeded.first), notice: 'Extraction was successfully created.'
        else
          redirect_to project_extractions_url(@project), notice: 'Extractions were successfully created.'
        end
      end
      format.json do
        render json: {
          success: {
            user_handle: projects_users_role.user.handle,
            citation_names: succeeded.map { |extraction| extraction.citation.name }
          },
          error: {
            user_handle: projects_users_role.user.handle,
            citation_names: failed.map { |extraction| extraction.citation.name }
          },
          info: {
            user_handle: projects_users_role.user.handle,
            citation_names: skipped.map { |extraction| extraction.citation.name }
          }
        }
      end
    rescue StandardError
      format.html { render :new }
      format.json { render json: lsof_extractions, status: :unprocessable_entity }
    end
  end

  # PATCH/PUT /extractions/1
  # PATCH/PUT /extractions/1.json
  def update
    authorize(@extraction.project, policy_class: ExtractionPolicy)
    redirect_path = params[:redirect_to]

    respond_to do |format|
      if @extraction.update(extraction_params)
        format.html do
          redirect_to(
            redirect_path || work_extraction_path(@extraction,
                                                  'panel-tab': params[:extraction][:extraction_forms_projects_section_id]),
            notice: t('success')
          )
        end
        format.json { render :show, status: :ok, location: @extraction }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @extraction.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update_kqp_selections
    respond_to do |format|
      format.js do
        @extraction.extractions_key_questions_projects_selections.destroy_all
        params[:extraction][:extractions_key_questions_projects_selection_ids].each do |kqp_id|
          if kqp_id.present?
            @extraction.extractions_key_questions_projects_selections.create(key_questions_project_id: kqp_id)
          end
        end
      end
    end
  end

  # DELETE /extractions/1
  # DELETE /extractions/1.json
  def destroy
    authorize(@extraction.project, policy_class: ExtractionPolicy)

    @extraction.destroy
    respond_to do |format|
      format.html do
        redirect_to project_extractions_url(@extraction.project), notice: 'Extraction was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  # GET /extractions/1/work
  def work
    @project = @extraction.project
    authorize(@project, policy_class: ExtractionPolicy)
    @nav_buttons.push('extractions', 'my_projects')

    set_extraction_forms_projects

    respond_to do |format|
      format.html do
      end

      format.js do
        @load_js = params['load-js']
        @ajax_section_loading_index = params['ajax-section-loading-index']
        @efp = ExtractionFormsProject.find(params[:efp_id])
        unless @panel_tab_id == 'keyquestions'
          @key_questions_projects_array_for_select = @project.key_questions_projects_array_for_select

          if @extraction_forms_projects.first.extraction_forms_project_type.name.eql? ExtractionFormsProjectType::DIAGNOSTIC_TEST
            @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
                        .by_section_name_and_extraction_id_and_extraction_forms_project_id('Diagnoses',
                                                                                           @extraction.id,
                                                                                           @extraction_forms_projects.first.id)
          else
            @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
                        .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                                           @extraction.id,
                                                                                           @extraction_forms_projects.first.id)
          end

          # If a specific 'Outcome' is requested we load it here.
          @eefpst1 = if params[:eefpst1_id].present?
                       ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id])
                     # Otherwise we choose the first 'Outcome' in the extraction to display.
                     else
                       @eefpst1s.first
                     end

          update_record_helper_dictionaries @extraction
        end
      end
    end
  end

  def change_outcome_in_results_section
    respond_to do |format|
      format.js do
        @eefpst1                   = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id])
        @extraction                = @eefpst1.extraction
        @consolidated_extraction   = @extraction
        update_record_helper_dictionaries(@consolidated_extraction)
        update_eefps_by_extraction_and_efps_dict(@consolidated_extraction)
        @extractions = Extraction.where(citations_project: @extraction.citations_project).where.not(id: @extraction.id)
        @extractions.each do |extraction|
          update_record_helper_dictionaries(extraction)
          update_eefps_by_extraction_and_efps_dict(extraction)
        end
        @project                   = @extraction.project
        @extraction_forms_projects = @project.extraction_forms_projects
        if @extraction_forms_projects.first.extraction_forms_project_type.eql?(ExtractionFormsProjectType.find_by(name: ExtractionFormsProjectType::STANDARD))
          @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
                      .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                                         @extraction.id,
                                                                                         @extraction_forms_projects.first.id)
        elsif @extraction_forms_projects.first.extraction_forms_project_type.eql?(ExtractionFormsProjectType.find_by(name: ExtractionFormsProjectType::DIAGNOSTIC_TEST))
          @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
                      .by_section_name_and_extraction_id_and_extraction_forms_project_id('Diagnoses',
                                                                                         @extraction.id,
                                                                                         @extraction_forms_projects.first.id)
        else
          next
        end
      end
    end
  end

  # GET /projects/1/extractions/comparison_tool
  def comparison_tool
    authorize(@project, policy_class: ExtractionPolicy)
    @nav_buttons.push('comparison_tool', 'my_projects')
    @citation_groups = @project.citation_groups
  end

  # GET /projects/1/extractions/consolidate
  def consolidate
    authorize(@project, policy_class: ExtractionPolicy)
    @panel_tab_id = params['panel-tab'] || 'keyquestions'

    set_extraction_forms_projects

    @consolidated_extraction   = @project.consolidated_extraction(@extractions.first.citations_project_id,
                                                                  current_user.id)
    @head_to_head              = head_to_head(@extraction_forms_projects, @extractions)
    @eefpst1s                  = ExtractionsExtractionFormsProjectsSectionsType1
                                 .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                                                    @consolidated_extraction.id,
                                                                                                    @extraction_forms_projects.first.id)
    @eefpst1                   = params[:eefpst1_id].present? ? ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id]) : @eefpst1s.first

    @consolidated_extraction.ensure_extraction_form_structure
    @consolidated_extraction.auto_consolidate(@extractions)

    update_record_helper_dictionaries @consolidated_extraction
    update_eefps_by_extraction_and_efps_dict @consolidated_extraction
    @extractions.each do |extraction|
      update_record_helper_dictionaries extraction
      update_eefps_by_extraction_and_efps_dict extraction
    end
  end

  # GET /projects/1/extractions/edit_type1_across_extractions
  def edit_type1_across_extractions
    authorize(@project, policy_class: ExtractionPolicy)

    @type1       = Type1.find(params[:type1_id])
    @efps        = ExtractionFormsProjectsSection.find(params[:efps_id])
    @eefps       = ExtractionsExtractionFormsProjectsSection.find(params[:eefps_id])

    @eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find_by(
      extractions_extraction_forms_projects_section: @eefps,
      type1: @type1
    )

    @preview_type1_change_propagation = @eefpst1.preview_type1_change_propagation
    respond_to do |format|
      format.html do
        render layout: false
      end
      format.json do
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project
               .find(params[:project_id])
  end

  def set_extraction
    @panel_tab_id = params['panel-tab'] || 'keyquestions'

    if @panel_tab_id == 'keyquestions'
      @extraction = Extraction
                    .find(params[:id])
    else
      @extraction = Extraction
                    .includes(
                      extractions_extraction_forms_projects_sections: {
                        extractions_extraction_forms_projects_sections_question_row_column_fields: %i[
                          records
                          extractions_extraction_forms_projects_sections_type1
                          extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options
                          question_row_columns_question_row_column_options
                        ]
                      },
                      projects_users_role: :projects_user
                    )
                    .find(params[:id])
    end
  end

  def set_extractions
    @extractions = policy_scope(Extraction)
                   .includes(
                     {
                       projects_users_role: { projects_user: { user: :profile } }
                     },
                     {
                       extractions_extraction_forms_projects_sections: [
                         { link_to_type1: [{ extraction_forms_projects_section: :section }] }, { statusing: :status }
                       ]
                     }
                   )
                   .where(id: extraction_ids_params)
  end

  def ensure_extraction_form_structure
    if @extractions
      @extractions.each { |extraction| extraction.ensure_extraction_form_structure }
    else
      @extraction.ensure_extraction_form_structure
    end
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def extraction_params
    params
      .require(:extraction)
      .permit(:projects_users_role_id,
              :citations_project_id,
              citations_project_ids: [],
              extractions_key_questions_project_ids: [],
              key_questions_project_ids: [])
  end

  def extraction_ids_params
    params.require(:extraction_ids)
  end

  def update_record_helper_dictionaries(extraction)
    @eefps_qrcf_dict ||= {}
    @records_dict ||= {}
    extraction.extractions_extraction_forms_projects_sections.each do |eefps|
      eefps
        .extractions_extraction_forms_projects_sections_question_row_column_fields
        .each do |eefps_qrcf|
        @eefps_qrcf_dict[[eefps.id, eefps_qrcf.question_row_column_field_id, eefps_qrcf.extractions_extraction_forms_projects_sections_type1&.type1_id].to_s] =
          eefps_qrcf
        @records_dict[eefps_qrcf.id] = if eefps_qrcf.records.blank?
                                         Record.find_or_create_by(recordable: eefps_qrcf)
                                       else
                                         eefps_qrcf.records.first
                                       end
      end
    end
  end

  def update_eefps_by_extraction_and_efps_dict(extraction)
    @eefps_by_extraction_and_efps_dict ||= {}
    @eefpst1_by_eefps_and_t1_dict ||= {}
    eefps_relation = extraction.extractions_extraction_forms_projects_sections.includes(
      { link_to_type1: [{ extraction_forms_projects_section: :section }, :type1s,
                        { extractions_extraction_forms_projects_sections_type1s: [:type1_type, :type1, { extractions_extraction_forms_projects_sections_type1_rows: :population_name }] }] }, { statusing: :status }
    )
    @eefps_by_extraction_and_efps_dict[extraction.id] =
      eefps_relation.group_by(&:extraction_forms_projects_section_id)
    eefps_relation.each do |eefps|
      @eefpst1_by_eefps_and_t1_dict[eefps.id] =
        eefps.extractions_extraction_forms_projects_sections_type1s.includes(extractions_extraction_forms_projects_sections_type1_rows: :population_name).group_by(&:type1_id)
    end
  end

  def set_eefps_by_efps_dict
    @eefps_by_efps_dict ||= @extraction.extractions_extraction_forms_projects_sections.group_by(&:extraction_forms_projects_section_id)
  end

  def set_extraction_forms_projects
    @extraction_forms_projects = @project.extraction_forms_projects.includes(:extraction_form)
  end
end
