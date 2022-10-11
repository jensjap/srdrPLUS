class ExtractionFormsProjectsController < ApplicationController
  before_action :set_project, only: [:create]
  before_action :set_extraction_forms_project, only: %i[build edit update destroy]
  before_action :skip_policy_scope

  # GET /extraction_forms_projects/1/edit
  def edit; end

  # POST /projects/1/extraction_forms_projects
  # POST /projects/1/extraction_forms_projects.json
  def create
    @extraction_forms_project = @project.extraction_forms_projects.build(extraction_forms_project_params)

    respond_to do |format|
      if @extraction_forms_project.save
        format.html do
          redirect_to edit_project_path(@project, anchor: 'panel-extraction-form'),
                      notice: t('success')
        end
        format.json { render :show, status: :created, location: @project }
      else
        format.html do
          redirect_to edit_project_path(@project, anchor: 'panel-extraction-form'),
                      alert: t('blank')
        end
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /extraction_forms_projects/1
  # PATCH/PUT /extraction_forms_projects/1.json
  def update
    respond_to do |format|
      if @extraction_forms_project.update(extraction_forms_project_params)
        format.html do
          redirect_to build_extraction_forms_project_path(@extraction_forms_project,
                                                          'panel-tab': @extraction_forms_project.extraction_forms_projects_sections.first.id),
                      notice: t('success')
        end
        format.js   {}
        format.json { render :show, status: :ok, location: @extraction_forms_project }
      else
        format.html { render :edit }
        format.json { render json: @extraction_forms_project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /extraction_forms_projects/1
  # DELETE /extraction_forms_projects/1.json
  def destroy
    @project = @extraction_forms_project.project
    @extraction_forms_project.destroy
    respond_to do |format|
      format.html do
        redirect_to edit_project_path(@project, anchor: 'panel-extraction-form'),
                    notice: t('removed')
      end
      format.json { head :no_content }
    end
  end

  # GET /extraction_forms_projects/1/build
  def build
    @nav_buttons.push('extractions_form_builder')
    if @extraction_forms_project.project.key_questions.blank?
      key_question = KeyQuestion.find_or_create_by(name: 'Default question')
      @extraction_forms_project.project.key_questions << key_question
    end
    @panel_tab = (params['panel-tab'].present? && params['panel-tab']) || @extraction_forms_project.default_section_id.to_s
    @key_questions_projects = @extraction_forms_project.project.key_questions_projects.includes(:key_question)
    @key_questions_projects_array_for_select = @extraction_forms_project.project.key_questions_projects_array_for_select
    @extraction_forms_projects_sections = @extraction_forms_project
                                          .extraction_forms_projects_sections
                                          .includes(%i[ordering section])
    add_breadcrumb 'my projects',  :projects_path
    add_breadcrumb 'edit project', edit_project_path(@extraction_forms_project.project)
    add_breadcrumb 'builder',      :build_extraction_forms_project_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:project_id])
    authorize(@project, policy_class: ExtractionFormsProjectPolicy)
  end

  def set_extraction_forms_project
    @extraction_forms_project = ExtractionFormsProject
                                .includes(:project)
                                .find(params[:id])
    authorize(@extraction_forms_project.project, policy_class: ExtractionFormsProjectPolicy)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def extraction_forms_project_params
    params.require(:extraction_forms_project)
          .permit(
            :extraction_forms_project_type_id,
            extraction_form_attributes: [:name]
          )
  end
end
