class ExtractionFormsProjectsSectionsController < ApplicationController
  before_action :set_extraction_forms_project, only: [:new, :create]
  before_action :set_extraction_forms_projects_section, only: [:edit, :update, :destroy, :preview, :add_quality_dimension]
  before_action :skip_policy_scope

  # GET /extraction_forms_projects/1/extraction_forms_projects_sections/new
  def new
    @extraction_forms_projects_section = @extraction_forms_project.extraction_forms_projects_sections.new
  end

  # GET /extraction_forms_projects_sections/1/edit
  def edit
  end

  # POST /extraction_forms_projects/1/extraction_forms_projects_sections
  # POST /extraction_forms_projects/1/extraction_forms_projects_sections.json
  def create
    @extraction_forms_projects_section = @extraction_forms_project.extraction_forms_projects_sections.new(extraction_forms_projects_section_params)

    respond_to do |format|
      if @extraction_forms_projects_section.save
        format.html { redirect_to build_extraction_forms_project_path(@extraction_forms_project,
                                                                      anchor: "panel-tab-#{ @extraction_forms_projects_section.id }"),
                      notice: t('success') }
        format.json { render :show, status: :created, location: @extraction_forms_projects_section }
      else
        format.html { render :new }
        format.json { render json: @extraction_forms_projects_section.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extraction_forms_projects_sections/1
  # PATCH/PUT /extraction_forms_projects_sections/1.json
  def update
    respond_to do |format|
      if @extraction_forms_projects_section.update(extraction_forms_projects_section_params)
        format.html { redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                                      anchor: "panel-tab-#{ @extraction_forms_projects_section.id }"),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @extraction_forms_projects_section }
      else
        format.html { render :edit }
        format.json { render json: @extraction_forms_projects_section.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @extraction_forms_project = @extraction_forms_projects_section.extraction_forms_project
    @extraction_forms_projects_section.destroy
    respond_to do |format|
      format.html { redirect_to build_extraction_forms_project_path(
                                  @extraction_forms_project,
                                  anchor: @extraction_forms_project.extraction_forms_projects_sections.blank? ?
                                          nil : "panel-tab-#{ @extraction_forms_project.extraction_forms_projects_sections.first.id }"),
                    notice: t('removed') }
      format.json { head :no_content }
    end
  end

  def preview
    @key_questions_projects_array_for_select = @extraction_forms_projects_section.project.key_questions_projects_array_for_select

    add_breadcrumb 'my projects',  :projects_path
    add_breadcrumb 'edit project', edit_project_path(@extraction_forms_projects_section.project)
    add_breadcrumb 'builder',      build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                                       anchor: "panel-tab-#{ @extraction_forms_projects_section.id }")
    add_breadcrumb "preview #{ @extraction_forms_projects_section.section.name } form", preview_extraction_forms_projects_section_path
  end

  def dissociate_type1
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(dissociate_type1_params[0])
    authorize(@extraction_forms_projects_section.project, policy_class: ExtractionFormsProjectsSectionPolicy)

    @extraction_forms_projects_section.type1s.destroy(Type1.find(dissociate_type1_params[1]))
    redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                    anchor: "panel-tab-#{ @extraction_forms_projects_section.id }"),
                                                    notice: t('success')
  end

  def add_quality_dimension
    #!!! Make sure this user has permission to add questions to this extraction form

    if @extraction_forms_projects_section.section.name == 'Risk of Bias Assessment'
      ExtractionFormsProjectsSection.add_quality_dimension_by_questions_or_section(params.require([:id, :a_qdqId]))
      redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                      anchor: "panel-tab-#{ @extraction_forms_projects_section.id }"),
                                                      notice: t('success')
    else
      redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                      anchor: "panel-tab-#{ @extraction_forms_projects_section.id }"),
                                                      alert: t('failure')
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_extraction_forms_project
      @extraction_forms_project = ExtractionFormsProject.find(params[:extraction_forms_project_id])
      authorize(@extraction_forms_project.project, policy_class: ExtractionFormsProjectsSectionPolicy)
    end

    def set_extraction_forms_projects_section
      @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:id])
      authorize(@extraction_forms_projects_section.project, policy_class: ExtractionFormsProjectsSectionPolicy)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_forms_projects_section_params
      params.require(:extraction_forms_projects_section)
        .permit(:extraction_forms_projects_section_type_id,
                :section_id,
                :extraction_forms_projects_section_id,
                key_questions_project_ids: [],
                extraction_forms_projects_section_option_attributes: [:id, :by_type1, :include_total],
                extraction_forms_projects_sections_type1s_attributes: [:type1_type_id, timepoint_name_ids: [], type1_attributes: [:id, :name, :description], timepoint_names_attributes: [:id, :name, :unit]])
    end

    def dissociate_type1_params
      params.require([:extraction_forms_projects_section_id, :type1_id])
    end
end
