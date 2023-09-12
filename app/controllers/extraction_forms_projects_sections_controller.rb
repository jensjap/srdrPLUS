class ExtractionFormsProjectsSectionsController < ApplicationController
  before_action :set_extraction_forms_project, only: %i[new create]
  before_action :set_extraction_forms_projects_section,
                only: %i[edit update destroy preview add_quality_dimension]
  before_action :skip_policy_scope

  # GET /extraction_forms_projects/1/extraction_forms_projects_sections/new
  def new
    @extraction_forms_projects_section = @extraction_forms_project
                                         .extraction_forms_projects_sections
                                         .new
    authorize(@extraction_forms_projects_section)
  end

  # GET /extraction_forms_projects_sections/1/edit
  def edit; end

  # POST /extraction_forms_projects/1/extraction_forms_projects_sections
  # POST /extraction_forms_projects/1/extraction_forms_projects_sections.json
  def create
    @extraction_forms_projects_section = @extraction_forms_project.extraction_forms_projects_sections.new(extraction_forms_projects_section_params)
    authorize(@extraction_forms_projects_section)

    respond_to do |format|
      if @extraction_forms_projects_section.save
        format.html do
          @extraction_forms_project.project.extractions.each do |extraction|
            extraction.ensure_extraction_form_structure
          end
          redirect_to build_extraction_forms_project_path(
            @extraction_forms_project,
            'panel-tab': @extraction_forms_projects_section.id
          ), notice: t('success')
        end
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
      @errors = @extraction_forms_projects_section.errors
      if @extraction_forms_projects_section.update(extraction_forms_projects_section_params)
        format.html do
          redirect_to build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                                          'panel-tab': @extraction_forms_projects_section.id),
                      notice: t('success')
        end
        format.json { render :show, status: :ok, location: @extraction_forms_projects_section }
        format.js {}
      else
        format.html { render :edit }
        format.json { render json: @errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @extraction_forms_project = @extraction_forms_projects_section.extraction_forms_project
    @extraction_forms_projects_section.destroy
    respond_to do |format|
      format.html do
        redirect_to build_extraction_forms_project_path(
          @extraction_forms_project, 'panel-tab': if @extraction_forms_project.extraction_forms_projects_sections.blank?
                                                    nil
                                                  else
                                                    @extraction_forms_project.extraction_forms_projects_sections.first.id
                                                  end
        ), notice: t('removed')
      end
      format.json { head :no_content }
    end
  end

  def dissociate_type1
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(dissociate_type1_params[0])
    authorize(@extraction_forms_projects_section)

    @extraction_forms_projects_section.type1s.destroy(Type1.find(dissociate_type1_params[1]))
    redirect_to(
      build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                          'panel-tab': @extraction_forms_projects_section.id),
      notice: t('success'),
      status: 303
    )
  end

  def add_quality_dimension
    # !!! Make sure this user has permission to add questions to this extraction form

    if @extraction_forms_projects_section.section.name == 'Risk of Bias Assessment'
      ExtractionFormsProjectsSection.add_quality_dimension_by_questions_or_section(params.require(%i[id a_qdqId]))
      redirect_to(
        build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project, 'panel-tab': @extraction_forms_projects_section.id),
        notice: t('success'), status: 303
      )
    else
      redirect_to(
        build_extraction_forms_project_path(@extraction_forms_projects_section.extraction_forms_project,
                                            'panel-tab': @extraction_forms_projects_section.id),
        alert: t('failure'),
        status: 303
      )
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_extraction_forms_project
    @extraction_forms_project = ExtractionFormsProject.find(params[:extraction_forms_project_id])
  end

  def set_extraction_forms_projects_section
    @extraction_forms_projects_section = ExtractionFormsProjectsSection.find(params[:id])
    authorize(@extraction_forms_projects_section)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def extraction_forms_projects_section_params
    params.require(:extraction_forms_projects_section)
          .permit(:extraction_forms_projects_section_type_id,
                  :section_id,
                  :extraction_forms_projects_section_id,
                  :helper_message,
                  key_questions_project_ids: [],
                  extraction_forms_projects_section_option_attributes: %i[id by_type1 include_total],
                  extraction_forms_projects_sections_type1s_attributes: [
                    :type1_type_id,
                    { timepoint_name_ids: [],
                      type1_attributes: %i[id name description],
                      timepoint_names_attributes: %i[id name unit],
                      extraction_forms_projects_sections_type1_rows_attributes: [:id, :name, :_destroy, {
                        population_name_attributes: %i[id name description]
                      }] }
                  ])
  end

  def dissociate_type1_params
    params.require(%i[extraction_forms_projects_section_id type1_id])
  end
end
