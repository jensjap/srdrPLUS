class Api::V3::SdOutcomesController < Api::V3::BaseController

  def show
    @sd_outcome = SdMetaDataSupplyingService.new.get_sd_outcome_by_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @sd_outcome }
      format.fhir_json { render json: @sd_outcome }
      format.html { render json: @sd_outcome }
      format.json { render json: @sd_outcome }
      format.xml { render xml: @sd_outcome }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

end
