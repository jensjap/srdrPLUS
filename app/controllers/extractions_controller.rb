class ExtractionsController < ApplicationController

  add_breadcrumb 'my projects', :projects_path

  include ExtractionsControllerHelpers

  before_action :set_project, only: [:index, :new, :create, :comparison_tool, :compare, :consolidate, :edit_type1_across_extractions]
  before_action :set_extraction, only: [:show, :edit, :update, :destroy, :work]
  before_action :set_extractions, only: [:consolidate, :edit_type1_across_extractions]
  before_action :ensure_extraction_form_structure, only: [:consolidate, :work]
  before_action :set_eefps_by_efps_dict, only: [:work]

  before_action :skip_policy_scope, except: [:compare, :consolidate, :edit_type1_across_extractions]
  before_action :skip_authorization, only: [:index, :show]

  # GET /projects/1/extractions
  # GET /projects/1/extractions.json
  def index
    @is_leader = false
    if @project.leaders.include? current_user
      @is_leader = false
      @extractions = @project.extractions
      @projects_users_roles = ProjectsUsersRole.joins(:projects_user).where(projects_users: { project: @project })
      @citation_groups = @project.citation_groups
    else
      @extractions = @project.extractions.joins(projects_users_role: :projects_user).where(projects_users_role: { projects_users: { user_id: current_user.id } })
      if @project.consolidators.include? current_user
        @citation_groups = @project.citation_groups
      else
        @citation_groups = []
      end
    end

    add_breadcrumb 'edit project', edit_project_path(@project)
    add_breadcrumb 'extractions',  :project_extractions_path
  end

  # GET /extractions/1
  # GET /extractions/1.json
  def show
  end

  # GET /extractions/new
  def new
    @extraction           = @project.extractions.new(citations_project: CitationsProject.new(project: @project))
    @citations_projects   = @project.citations_projects
    @citations            = @project.citations
    @projects_users_roles = ProjectsUsersRole.joins(:projects_user).where(projects_users: { project: @project })
    @current_projects_users_role = ProjectsUsersRole.joins(:projects_user).where(projects_users: { user: current_user, project: @project }).order(role_id: :asc).first

    authorize(@extraction.project, policy_class: ExtractionPolicy)

    add_breadcrumb 'extractions',    :project_extractions_path
    add_breadcrumb 'new extraction', :new_project_extraction_path
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
    lsof_extractions = Array.new
    params["extraction"]["citation"].delete_if { |i| i=="" }.map(&:to_i).each do |citation_id|
      lsof_extractions << @project.extractions.build(
        citations_project: CitationsProject.find_by(citation_id: citation_id, project: @project),
        projects_users_role_id: params["extraction"]["projects_users_role_id"].to_i)
    end

    authorize(@project, policy_class: ExtractionPolicy)

    respond_to do |format|
      begin
        lsof_extractions.map{ |e| e.save }
        format.html { redirect_to project_extractions_url(@project), notice: 'Extractions was successfully created.' }
        format.json { render :show, status: :created, location: @extraction }
      rescue
        format.html { render :new }
        format.json { render json: lsof_extractions, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extractions/1
  # PATCH/PUT /extractions/1.json
  def update
    authorize(@extraction.project, policy_class: ExtractionPolicy)

    respond_to do |format|
      if @extraction.update(extraction_params)
        format.html { redirect_to work_extraction_path(@extraction,
                                                       anchor: "panel-tab-#{ params[:extraction][:extraction_forms_projects_section_id] }"),
                                                       notice: t('success') }
        format.json { render :show, status: :ok, location: @extraction }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @extraction.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /extractions/1
  # DELETE /extractions/1.json
  def destroy
    authorize(@extraction.project, policy_class: ExtractionPolicy)

    @extraction.destroy
    respond_to do |format|
      format.html { redirect_to project_extractions_url(@extraction.project), notice: 'Extraction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /extractions/1/work
  def work
    @project = @extraction.project
    authorize(@project, policy_class: ExtractionPolicy)

    set_extraction_forms_projects

    @key_questions_projects_array_for_select = @project.key_questions_projects_array_for_select

    if @extraction_forms_projects.first.extraction_forms_project_type.eql? ExtractionFormsProjectType::STANDARD
      # If a specific 'Outcome' is requested we load it here.
      @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                           @extraction.id,
                                                                           @extraction_forms_projects.first.id)

    elsif @extraction_forms_projects.first.extraction_forms_project_type.eql? ExtractionFormsProjectType::DIAGNOSTIC_TEST
      # If a specific 'Outcome' is requested we load it here.
      @eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id('Diagnostic Tests',
                                                                           @extraction.id,
                                                                           @extraction_forms_projects.first.id)

    else
      raise "Unkown ExtractionFormsProjectType"
    end

    if params[:eefpst1_id].present?
      @eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id])

    # Otherwise we choose the first 'Outcome' in the extraction to display.
    else
      @eefpst1 = @eefpst1s.first
    end

    update_record_helper_dictionaries @extraction

    add_breadcrumb 'edit project', edit_project_path(@project)
    add_breadcrumb 'extractions',  project_extractions_path(@project)
    add_breadcrumb 'work',         :work_extraction_path
  end

  def change_outcome_in_results_section
    respond_to do |format|
      format.js do
        @eefpst1                   = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id])
        @extraction                = @eefpst1.extraction
        @project                   = @extraction.project
        @extraction_forms_projects = @project.extraction_forms_projects
        @eefpst1s                  = ExtractionsExtractionFormsProjectsSectionsType1
          .by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes',
                                                                             @extraction.id,
                                                                             @extraction_forms_projects.first.id)
      end
    end
  end

  # GET /projects/1/extractions/comparison_tool
  def comparison_tool
    authorize(@project, policy_class: ExtractionPolicy)

    @citation_groups = @project.citation_groups

    add_breadcrumb 'edit project',    edit_project_path(@project)
    add_breadcrumb 'extractions',     :project_extractions_path
    add_breadcrumb 'comparison tool', :comparison_tool_project_extractions_path
  end

  # GET /projects/1/extractions/consolidate
  def consolidate
    authorize(@project, policy_class: ExtractionPolicy)

    set_extraction_forms_projects

    @consolidated_extraction   = @project.consolidated_extraction(@extractions.first.citations_project_id, current_user.id)
    @head_to_head              = head_to_head(@extraction_forms_projects, @extractions)
    @preselected_eefpst1       = params[:eefpst1_id].present? ? ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id]) : nil
    @consolidated_extraction.ensure_extraction_form_structure
    @consolidated_extraction.auto_consolidate(@extractions)

    update_record_helper_dictionaries @consolidated_extraction
    update_eefps_by_extraction_and_efps_dict @consolidated_extraction
    @extractions.each do |extraction|
      update_record_helper_dictionaries extraction
      update_eefps_by_extraction_and_efps_dict extraction
    end

    add_breadcrumb 'edit project',    edit_project_path(@project)
    add_breadcrumb 'extractions',     :project_extractions_path
    add_breadcrumb 'comparison tool', :comparison_tool_project_extractions_path
    add_breadcrumb 'consolidate',     :consolidate_project_extractions_path
  end

  # GET /projects/1/extractions/edit_type1_across_extractions
  def edit_type1_across_extractions
    authorize(@project, policy_class: ExtractionPolicy)

    @type1       = Type1.find(params[:type1_id])
    @efps        = ExtractionFormsProjectsSection.find(params[:efps_id])
    @eefps       = ExtractionsExtractionFormsProjectsSection.find(params[:eefps_id])

    @eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find_by(
      extractions_extraction_forms_projects_section: @eefps,
      type1: @type1)

    @preview_type1_change_propagation = @eefpst1.preview_type1_change_propagation

    render layout: false
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.
        includes(extraction_forms_projects: { extraction_forms_projects_sections: { extractions_extraction_forms_projects_sections: :extraction } }).
        includes(extractions: { extractions_extraction_forms_projects_sections: { extraction_forms_projects_section: :extraction_forms_project } }).
        find(params[:project_id])
    end

    def set_extraction
      @extraction = Extraction.
        includes(projects_users_role: { projects_user: :project }).
        find(params[:id])
        #.includes(key_questions_projects: [:key_question, extraction_forms_projects_section: [:extractions_extraction_forms_projects_sections, :extraction_forms_projects_section_type]])
    end

    def set_extractions
      @extractions = policy_scope(Extraction).
        includes({projects_users_role: { projects_user: { user: :profile } }}, {extractions_extraction_forms_projects_sections: [{link_to_type1: [{extraction_forms_projects_section: :section}, :type1s, {extractions_extraction_forms_projects_sections_type1s: [:type1_type, :type1]}]}, {statusing: :status}]}).
        where(id: extraction_ids_params)
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
      params.
        require(:extraction).
        permit(:projects_users_role_id,
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
        eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.includes([:records, :extractions_extraction_forms_projects_sections_type1]).each do |eefps_qrcf|
          @eefps_qrcf_dict[[eefps.id,eefps_qrcf.question_row_column_field_id,eefps_qrcf.extractions_extraction_forms_projects_sections_type1&.type1_id].to_s] = eefps_qrcf
          if eefps_qrcf.records.blank?
            @records_dict[eefps_qrcf.id] = Record.find_or_create_by(recordable: eefps_qrcf)
          else
            @records_dict[eefps_qrcf.id] = eefps_qrcf.records.first
          end
        end
      end
    end

    
    def update_eefps_by_extraction_and_efps_dict(extraction)
      @eefps_by_extraction_and_efps_dict ||= {}
      @eefpst1_by_eefps_and_t1_dict ||= {}
      eefps_relation = extraction.extractions_extraction_forms_projects_sections.includes({link_to_type1: [{extraction_forms_projects_section: :section}, :type1s, {extractions_extraction_forms_projects_sections_type1s: [:type1_type, :type1, {extractions_extraction_forms_projects_sections_type1_rows: :population_name}]}]}, {statusing: :status})
      @eefps_by_extraction_and_efps_dict[extraction.id] = eefps_relation.group_by(&:extraction_forms_projects_section_id)
      eefps_relation.each do |eefps|
        @eefpst1_by_eefps_and_t1_dict[eefps.id] = eefps.extractions_extraction_forms_projects_sections_type1s.includes(extractions_extraction_forms_projects_sections_type1_rows: :population_name).group_by(&:type1_id)
      end
    end

    def set_eefps_by_efps_dict
      @eefps_by_efps_dict ||= @extraction.extractions_extraction_forms_projects_sections.includes({link_to_type1: [{extraction_forms_projects_section: :section}, :type1s, {extractions_extraction_forms_projects_sections_type1s: [:type1_type, :type1]}]}, {statusing: :status}).group_by(&:extraction_forms_projects_section_id)
    end

    def set_extraction_forms_projects
      @extraction_forms_projects = @project.extraction_forms_projects.includes( extraction_forms_projects_sections: [:extraction_forms_projects_section_option, :extraction_forms_projects_section_type, :section, :type1s, {questions: [:dependencies, :key_questions_projects, {question_rows: [{question_row_columns: [:question_row_column_type, :question_row_column_fields, {question_row_columns_question_row_column_options: [:followup_field]}]}]}]}])
    end
end
