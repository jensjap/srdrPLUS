class ExtractionFormsProjectsSectionsController < ApplicationController
  before_action :set_extraction_forms_project, only: [:new, :create]
  before_action :set_extraction_forms_projects_section, only: [:edit, :update, :destroy]

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

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_extraction_forms_project
      @extraction_forms_project = ExtractionFormsProject.find(params[:extraction_forms_project_id])
    end

    def set_extraction_forms_projects_section
      @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extraction_forms_projects_section_params
      params.require(:extraction_forms_projects_section).permit(
        :extraction_forms_projects_section_type_id,
        :section_id,
        questions_attributes: [:id, :_destroy, :name, :description, :question_type_id]
      )
    end
end
