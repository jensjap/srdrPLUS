class ExtractionsExtractionFormsProjectsSectionsType1RowsController < ApplicationController
  before_action :set_extractions_extraction_forms_projects_sections_type1, only: [:create]

  # POST /extractions_extraction_forms_projects_sections_type1s/:extractions_extraction_forms_projects_sections_type1_id/extractions_extraction_forms_projects_sections_type1_rows
  # POST /extractions_extraction_forms_projects_sections_type1s/:extractions_extraction_forms_projects_sections_type1_id/extractions_extraction_forms_projects_sections_type1_rows.json
  def create
    @extractions_extraction_forms_projects_sections_type1_row = @extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.build(extractions_extraction_forms_projects_sections_type1_row_params)

    respond_to do |format|
      if @extractions_extraction_forms_projects_sections_type1_row.save
        format.html { redirect_to edit_timepoints_extractions_extraction_forms_projects_sections_type1_path(@extractions_extraction_forms_projects_sections_type1),
                      notice: t('success') }
        format.json { head :no_content }
      else
        format.html { render '/extractions_extraction_forms_projects_sections_type1s/edit_timepoints' }
        format.json { render :json => @extractions_extraction_forms_projects_sections_type1_row.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

    def set_extractions_extraction_forms_projects_sections_type1
      @extractions_extraction_forms_projects_sections_type1 = ExtractionsExtractionFormsProjectsSectionsType1.find(params[:extractions_extraction_forms_projects_sections_type1_id])
    end

    def extractions_extraction_forms_projects_sections_type1_row_params
      params.require(:extractions_extraction_forms_projects_sections_type1_row)
        .permit(:name, :unit, :is_baseline)
    end
end
