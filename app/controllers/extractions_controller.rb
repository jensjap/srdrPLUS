class ExtractionsController < ApplicationController

  add_breadcrumb 'my projects', :projects_path

  include ExtractionsControllerHelpers

  before_action :set_project, only: [:index, :new, :create, :comparison_tool, :compare, :consolidate]
  before_action :set_extraction, only: [:show, :edit, :update, :destroy, :work]
  before_action :set_extractions, only: [:consolidate, :edit_type1_across_extractions]
  before_action :ensure_extraction_form_structure, only: [:consolidate, :work]

  before_action :skip_policy_scope, except: [:compare, :consolidate, :edit_type1_across_extractions]
  before_action :skip_authorization, only: [:index, :show]

  # GET /projects/1/extractions
  # GET /projects/1/extractions.json
  def index
    @extractions = @project.extractions
    @citation_groups = @project.citation_groups

    add_breadcrumb 'edit project', edit_project_path(@project)
    add_breadcrumb 'extractions',  :project_extractions_path
  end

  # GET /extractions/1
  # GET /extractions/1.json
  def show
  end

  # GET /extractions/new
  def new
    @extraction = @project.extractions.new

    authorize(@extraction.project, policy_class: ExtractionPolicy)

    add_breadcrumb 'extractions',    :project_extractions_path
    add_breadcrumb 'new extraction', :new_project_extraction_path
  end

  # GET /extractions/1/edit
  def edit
    authorize(@extraction.project, policy_class: ExtractionPolicy)
  end

  # POST /extractions
  # POST /extractions.json
  def create
    @extraction = @project.extractions.build(extraction_params)

    authorize(@extraction.project, policy_class: ExtractionPolicy)

    respond_to do |format|
      if @extraction.save
        format.html { redirect_to project_extractions_url(@extraction.project), notice: 'Extraction was successfully created.' }
        format.json { render :show, status: :created, location: @extraction }
      else
        format.html { render :new }
        format.json { render json: @extraction.errors, status: :unprocessable_entity }
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
      else
        format.html { render :edit }
        format.json { render json: @extraction.errors, status: :unprocessable_entity }
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
    authorize(@extraction.project, policy_class: ExtractionPolicy)

    @extraction_forms_projects = @extraction.project.extraction_forms_projects
    @key_questions_projects_array_for_select = @extraction.project.key_questions_projects_array_for_select
    @preselected_eefpst1 = params[:eefpst1_id].present? ? ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id]) : nil

    add_breadcrumb 'edit project', edit_project_path(@extraction.project)
    add_breadcrumb 'extractions',  project_extractions_path(@extraction.project)
    add_breadcrumb 'work',         :work_extraction_path
  end

  # GET /projects/1/extractions/comparison_tool
  def comparison_tool
    authorize(@project, policy_class: ExtractionPolicy)
    @extractions = policy_scope(Extraction).
      includes(projects_users_role: { projects_user: { user: :profile } })
    @extractions.map(&:ensure_extraction_form_structure)

    @citation_groups = @project.citation_groups

    add_breadcrumb 'edit project',    edit_project_path(@project)
    add_breadcrumb 'extractions',     :project_extractions_path
    add_breadcrumb 'comparison tool', :comparison_tool_project_extractions_path
  end

  # GET /projects/1/extractions/consolidate
  def consolidate
    authorize(@project, policy_class: ExtractionPolicy)

    @extraction_forms_projects = @project.extraction_forms_projects
    @consolidated_extraction   = @project.consolidated_extraction(@extractions.first.citations_project_id, current_user.id)
    @head_to_head              = head_to_head(@extraction_forms_projects, @extractions)
    @preselected_eefpst1       = params[:eefpst1_id].present? ? ExtractionsExtractionFormsProjectsSectionsType1.find(params[:eefpst1_id]) : nil
    @consolidated_extraction.ensure_extraction_form_structure
    @consolidated_extraction.auto_consolidate(@extractions)

    add_breadcrumb 'edit project',    edit_project_path(@project)
    add_breadcrumb 'extractions',     :project_extractions_path
    add_breadcrumb 'comparison tool', :comparison_tool_project_extractions_path
    add_breadcrumb 'consolidate',     :consolidate_project_extractions_path
  end

  # GET /projects/1/extractions/edit_type1_across_extractions
  def edit_type1_across_extractions
    authorize(@extraction.project, policy_class: ExtractionPolicy)

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
        includes(projects_users_role: { projects_user: { user: :profile } }).
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
        permit(:citations_project_id,
          :projects_users_role_id,
          extractions_key_questions_project_ids: [],
          key_questions_project_ids: [])
    end

    def extraction_ids_params
      params.require(:extraction_ids)
    end
end
