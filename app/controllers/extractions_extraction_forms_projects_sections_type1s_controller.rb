class ExtractionsExtractionFormsProjectsSectionsType1sController < ApplicationController
  before_action :set_extractions_extraction_forms_projects_sections_type1, only: [:edit, :update, :destroy, :edit_timepoints, :edit_populations]

  # GET /extractions_extraction_forms_projects_sections_type1/1/edit
  def edit
    #@extractions_extraction_forms_projects_sections_type1_row = @extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.build
  end

  # PATCH/PUT /extractions_extraction_forms_projects_sections_type1/1
  # PATCH/PUT /extractions_extraction_forms_projects_sections_type1/1.json
  def update
    respond_to do |format|
      if @extractions_extraction_forms_projects_sections_type1.update(extractions_extraction_forms_projects_sections_type1_params)
        format.html { redirect_to work_extraction_path(@extractions_extraction_forms_projects_sections_type1
                                                         .extractions_extraction_forms_projects_section
                                                         .extraction,
                                                       anchor: "panel-tab-#{ @extractions_extraction_forms_projects_sections_type1
                                                               .extractions_extraction_forms_projects_section.id }"),
                                                       notice: t('success') }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @extractions_extraction_forms_projects_sections_type1.errors, status: :unprocessable_entity }
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
                                                     anchor: "panel-tab-#{ @extractions_extraction_forms_projects_sections_type1
                                                             .extractions_extraction_forms_projects_section.id }"),
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
    @extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
      eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.create
    end

    redirect_to edit_populations_extractions_extraction_forms_projects_sections_type1(@extractions_extraction_forms_projects_sections_type1), notice: t('success')
  end

  def get_results_populations
    @next_eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_extractions_extraction_forms_projects_sections_type1
      @extractions_extraction_forms_projects_sections_type1 = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def extractions_extraction_forms_projects_sections_type1_params
      params.require(:extractions_extraction_forms_projects_sections_type1)
        .permit(:type1_type_id, :extractions_extraction_forms_projects_section_id, :type1_id, :units,
          type1_attributes: [:id, :name, :description],
          extractions_extraction_forms_projects_sections_type1_rows_attributes: [:id, :_destroy,
            population_name_attributes: [:id, :name, :description],
            extractions_extraction_forms_projects_sections_type1_row_columns_attributes: [:id, :_destroy,
              timepoint_name_attributes: [:id, :name, :unit]]])
    end
end
