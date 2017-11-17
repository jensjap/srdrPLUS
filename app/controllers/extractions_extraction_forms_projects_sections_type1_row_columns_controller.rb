class ExtractionsExtractionFormsProjectsSectionsType1RowColumnsController < ApplicationController
  before_action :set_extractions_extraction_forms_projects_sections_type1_row, only: [:create]

  # POST /extractions_extraction_forms_projects_sections_type1_rows/:extractions_extraction_forms_projects_sections_type1_row_id/extractions_extraction_forms_projects_sections_type1_row_columns
  # POST /extractions_extraction_forms_projects_sections_type1_rows/:extractions_extraction_forms_projects_sections_type1_row_id/extractions_extraction_forms_projects_sections_type1_row_columns.json
  def create
    respond_to do |format|
      @extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
        extractions_extraction_forms_projects_sections_type1_row_column = eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.build(extractions_extraction_forms_projects_sections_type1_row_column_params)

        unless extractions_extraction_forms_projects_sections_type1_row_column.save
          format.html { render '/extractions_extraction_forms_projects_sections_type1s/edit_populations' }
          format.json { render :json => extractions_extraction_forms_projects_sections_type1_row_column.errors, :status => :unprocessable_entity }
        end
      end

      format.html { redirect_to edit_populations_extractions_extraction_forms_projects_sections_type1_path(@extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1),
                    notice: t('success') }
      format.json { head :no_content }
    end
  end

  private

    def set_extractions_extraction_forms_projects_sections_type1_row
      @extractions_extraction_forms_projects_sections_type1_row = ExtractionsExtractionFormsProjectsSectionsType1Row.find(params[:extractions_extraction_forms_projects_sections_type1_row_id])
    end

    def extractions_extraction_forms_projects_sections_type1_row_column_params
      params.require(:extractions_extraction_forms_projects_sections_type1_row_column)
        .permit(:name, :description)
    end
end
