class ResultStatisticSectionsController < ApplicationController
  before_action :set_result_statistic_section, only: [:edit, :update]
  before_action :set_arms, only: [:edit, :update]

  # GET /result_statistic_sections/1/edit
  def edit
  end

  # PATCH/PUT /result_statistic_sections/1
  # PATCH/PUT /result_statistic_sections/1.json
  def update
    respond_to do |format|
      if @result_statistic_section.update(result_statistic_section_params)
        format.html { redirect_to edit_result_statistic_section_path(@result_statistic_section),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @result_statistic_section }
      else
        format.html { render :edit }
        format.json { render json: @result_statistic_section.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_arms
      @arms = ExtractionsExtractionFormsProjectsSectionsType1.by_section_name_and_extraction_id_and_extraction_forms_project_id('Arms',
      @result_statistic_section.subgroup.extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction.id,
      @result_statistic_section.subgroup.extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.extraction_forms_project.id,
      )
    end

    def set_result_statistic_section
      @result_statistic_section = ResultStatisticSection
        .includes(subgroup: { extractions_extraction_forms_projects_sections_type1_row: { extractions_extraction_forms_projects_sections_type1: [ :type1, extractions_extraction_forms_projects_section: [ :extraction, extraction_forms_projects_section: :extraction_forms_project ] ] } })
        .includes(:result_statistic_section_type)
        .find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def result_statistic_section_params
      params.require(:result_statistic_section).permit( 
        comparisons_attributes: [ :id, :_destroy, :result_statistic_section_id,
          comparisons_measures_attributes: [ :id, :_destroy, :comparison_id, :measure_id ],
          measurements_attributes: [ :id, :_destroy, :comparisons_measure_id, :value ],
        comparate_groups_attributes: [ :id, :_destroy, :comparison_id, 
        comparates_attributes: [ :id, :_destroy, :comparate_group_id, :comparable_element_id, 
        comparable_element_attributes: [ :id, :_destroy, :comparable_type, :comparable_id, :_destroy ] ] ] ] )
    end
end
