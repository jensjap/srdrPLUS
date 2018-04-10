class RecordsController < ApplicationController
  before_action :set_record, only: [:update]

  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)
        format.html { redirect_to work_extraction_path(@record.recordable.extraction,
                                                       anchor: "panel-tab-#{ @record.recordable.extractions_extraction_forms_projects_section.id.to_s }"),
                      notice: t('success') }
        format.json { render :show, status: :ok, location: @record }
      else
        format.html { redirect_to work_extraction_path(@record.recordable.extraction,
                                                       anchor: "panel-tab-#{ @record.recordable.extractions_extraction_forms_projects_section.id.to_s }"),
                                  alert: t('failure') }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_record
    @record = Record.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def record_params
    params.require(:record).permit(:value)
  end
end
