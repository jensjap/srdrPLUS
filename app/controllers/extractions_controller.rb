class ExtractionsController < ApplicationController
  include ExtractionsControllerHelpers

  before_action :set_project, only: [:index, :new, :create, :comparison_tool, :consolidate]
  before_action :set_extraction, only: [:show, :edit, :update, :destroy, :work]
  before_action :set_extractions, only: [:consolidate]
  before_action :ensure_extraction_form_structure, only: [:consolidate, :work]

  # GET /projects/1/extractions
  # GET /projects/1/extractions.json
  def index
    @extractions = @project.extractions
#    @extractions = Extraction.includes(:citations_project,
#                                       projects_users_role: [projects_user: [:project, user: [:profile]]],
#                                       extractions_key_questions_projects: [key_questions_project: [:key_question, extraction_forms_projects_section: [extraction_forms_project: [:extraction_form]]]])
#                             .where(extractions_key_questions_projects: { key_questions_projects: { project: @project } }).all
  end

  # GET /extractions/1
  # GET /extractions/1.json
  def show
  end

  # GET /extractions/new
  def new
    @extraction = Extraction.new
  end

  # GET /extractions/1/edit
  def edit
  end

  # POST /extractions
  # POST /extractions.json
  def create
    @extraction = @project.extractions.build(extraction_params)

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
    @extraction.destroy
    respond_to do |format|
      format.html { redirect_to project_extractions_url(@extraction.extraction_forms_project.project), notice: 'Extraction was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /extractions/1/work
  def work
    @extraction_forms_projects = @extraction.project.extraction_forms_projects
    @key_questions_projects_array_for_select = @extraction.project.key_questions_projects_array_for_select
  end

  # GET /projects/1/extractions/comparison_tool
  def comparison_tool
    @citation_groups = @project.citation_groups
  end

  # GET /projects/1/extractions/consolidate
  def consolidate
    @extraction_forms_projects = @project.extraction_forms_projects
    @extractions               = Extraction.where(id: extraction_ids_params)
    @head_to_head              = head_to_head(@extraction_forms_projects, @extractions)
    #byebug
    #@key_questions_projects_array_for_select = @extractions.first.project.key_questions_projects_array_for_select
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_extraction
      @extraction = Extraction.includes(projects_users_role: { projects_user: :project })
                              .find(params[:id])
                              #.includes(key_questions_projects: [:key_question, extraction_forms_projects_section: [:extractions_extraction_forms_projects_sections, :extraction_forms_projects_section_type]])
    end

    def set_extractions
      @extractions = Extraction.where(id: extraction_ids_params)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_params
      params.require(:extraction).permit(:citations_project_id,
                                         :projects_users_role_id,
                                         extractions_key_questions_project_ids: [],
                                         key_questions_project_ids: [])
    end

    def extraction_ids_params
      params.require(:extraction_ids)
    end

    def ensure_extraction_form_structure
      if @extractions
        @extractions.each { |extraction| extraction.ensure_extraction_form_structure }
      else
        @extraction.ensure_extraction_form_structure
      end
    end
end
