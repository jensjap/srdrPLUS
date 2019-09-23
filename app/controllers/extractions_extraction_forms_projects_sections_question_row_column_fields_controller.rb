class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsController < ApplicationController
  before_action :set_eefps_qrcf, :skip_policy_scope, only: [:update]

  def update
    authorize(@eefps_qrcf.project , policy_class: ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldPolicy)

    respond_to do |format|
      if @eefps_qrcf.update(eefps_qrcf_params)
        format.html { redirect_to work_extraction_path(@eefps_qrcf.extractions_extraction_forms_projects_section.extraction,
                                                       anchor: "panel-tab-#{ @eefps_qrcf.extractions_extraction_forms_projects_section.id.to_s }"),
                                  notice: t('success') }
        format.json { render :show, status: :ok, location: @eefps_qrcf }
        format.js do
          @info = [true, 'Saved!', '#410093']
        end
      else
        format.html { redirect_to work_extraction_path(@eefps_qrcf.extractions_extraction_forms_projects_section.extraction,
                                                       anchor: "panel-tab-#{ @eefps_qrcf.extractions_extraction_forms_projects_section.id.to_s }"),
                                  notice: t('success') }
        format.json { render json: @eefps_qrcf.errors, status: :unprocessable_entity }
        format.js do
          @info = [false, @eefps_qrcf.errors.full_messages.first, 'red']
        end
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_eefps_qrcf
    @eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def eefps_qrcf_params
    # We need to permit both the string :name and array :name.
    params.require(:extractions_extraction_forms_projects_sections_question_row_column_field)
      .permit(question_row_columns_question_row_column_option_ids: [])
  end
end
