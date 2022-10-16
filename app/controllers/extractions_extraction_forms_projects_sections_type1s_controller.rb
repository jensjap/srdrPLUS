class ExtractionsExtractionFormsProjectsSectionsType1sController < ApplicationController
  before_action :set_extractions_extraction_forms_projects_sections_type1, only: [:edit, :update, :destroy, :edit_timepoints, :edit_populations]
  before_action :skip_policy_scope

  # GET /extractions_extraction_forms_projects_sections_type1/1/edit
  def edit
    @project = @extractions_extraction_forms_projects_sections_type1.project
  end

  # PATCH/PUT /extractions_extraction_forms_projects_sections_type1/1
  # PATCH/PUT /extractions_extraction_forms_projects_sections_type1/1.json
  def update
    # A bit of security here to ensure we get values we expected:
    #   - 'false'
    #   - 'citations'
    #   - 'project'
    propagation_scope = { 'false' => false, 'citations' => :citations, 'project' => :project }[extractions_extraction_forms_projects_sections_type1_params.dig(:should, :propagate)]

    # If we want to propagate then do it now.
    @extractions_extraction_forms_projects_sections_type1.propagate_type1_change(propagation_scope, extractions_extraction_forms_projects_sections_type1_params) if propagation_scope

    respond_to do |format|
      if @extractions_extraction_forms_projects_sections_type1.update(extractions_extraction_forms_projects_sections_type1_params)
        format.html { redirect_to work_extraction_path(@extractions_extraction_forms_projects_sections_type1.extraction,
                                                       'panel-tab': @extractions_extraction_forms_projects_sections_type1
                                                               .extractions_extraction_forms_projects_section
                                                               .extraction_forms_projects_section.id),
                                                       notice: t('success') }
        format.json { head :no_content }
        format.js {}
      else
        format.html do
          flash[:alert] = @extractions_extraction_forms_projects_sections_type1.errors.messages.values.dig(0, 0)
          render :edit
        end
        format.json { render json: @extractions_extraction_forms_projects_sections_type1.errors, status: :unprocessable_entity }
        format.js {}
      end
    end
  end

  # DELETE /extractions_extraction_forms_projects_sections_type1/1
  # DELETE /extractions_extraction_forms_projects_sections_type1/1.json
  def destroy
    @extractions_extraction_forms_projects_sections_type1.destroy
    respond_to do |format|
      format.html { redirect_to work_extraction_path(@extractions_extraction_forms_projects_sections_type1
                                                       .extractions_extraction_forms_projects_section
                                                       .extraction,
                                                     'panel-tab': @extractions_extraction_forms_projects_sections_type1
                                                             .extractions_extraction_forms_projects_section
                                                             .extraction_forms_projects_section
                                                             .id),
                                                     notice: t('removed') }
      format.json { head :no_content }
    end
  end

  # GET /extractions_extraction_forms_projects_sections_type1s/1/edit_timepoints
  def edit_timepoints
  end

  # GET /extractions_extraction_forms_projects_sections_type1s/1/edit_populations
  def edit_populations
  end

  # POST /extractions_extraction_forms_projects_sections_type1s/1/add_population
  # POST /extractions_extraction_forms_projects_sections_type1s/1/add_population.json
  def add_population
    authorize(@extractions_extraction_forms_projects_sections_type1.project, policy_class: ExtractionsExtractionFormsProjectsSectionsType1Policy)

    @extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
      eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.create
    end

    redirect_to edit_populations_extractions_extraction_forms_projects_sections_type1(@extractions_extraction_forms_projects_sections_type1), notice: t('success')
  end

  def get_results_populations
    @next_eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:id])
    authorize(@next_eefpst1.project, policy_class: ExtractionsExtractionFormsProjectsSectionsType1Policy)

    @extractions = @next_eefpst1
      .extractions_extraction_forms_projects_section
      .extraction
      .project
      .extractions
      .unconsolidated
      .where(citations_project: @next_eefpst1.extractions_extraction_forms_projects_section.extraction.citations_project)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extractions_extraction_forms_projects_sections_type1
      @extractions_extraction_forms_projects_sections_type1 = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:id])
      authorize(@extractions_extraction_forms_projects_sections_type1.project, policy_class: ExtractionsExtractionFormsProjectsSectionsType1Policy)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extractions_extraction_forms_projects_sections_type1_params
      params.require(:extractions_extraction_forms_projects_sections_type1)
        .permit(:type1_type_id, :extractions_extraction_forms_projects_section_id, :type1_id, :units,
          should: :propagate,
          type1_attributes: [:id, :name, :description],
          extractions_extraction_forms_projects_sections_type1_rows_attributes: [:id, :_destroy,
            population_name_attributes: [:id, :name, :description],
            extractions_extraction_forms_projects_sections_type1_row_columns_attributes: [:id, :_destroy,
              timepoint_name_attributes: [:id, :name, :unit]]])
    end
end
