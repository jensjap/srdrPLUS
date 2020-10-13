class RecordsController < ApplicationController
  before_action :set_record, :skip_policy_scope, :skip_authorization, only: [:update]

  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)
        format.html { redirect_to edit_result_statistic_section_path(@record.recordable.result_statistic_section), notice: t('success') }
        format.json { render :show, status: :ok, location: @record }
        format.js do
          @info = [true, 'Saved!', '#410093']
        end
      else
        format.html { redirect_to work_extraction_path(@record.recordable.extraction,
                                                       'panel-tab': @record.recordable.extractions_extraction_forms_projects_section.id.to_s),
                                  alert: t('failure') + ' ' + @record.errors.full_messages.to_s }
        format.json { render json: @record.errors, status: :unprocessable_entity }
        format.js do
          @info = [false, @record.errors.full_messages.first, 'red']
        end
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
      # We need to permit both the string :name and array :name.
      params.require(:record).permit(:name, :select2, :select2Multi, name: [])
    end
end
