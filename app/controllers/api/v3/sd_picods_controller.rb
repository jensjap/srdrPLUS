class Api::V3::SdPicodsController < Api::V3::BaseController

  def show
    @sd_picod = SdMetaDataSupplyingService.new.get_sd_picod_by_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @sd_picod }
      format.fhir_json { render json: @sd_picod }
      format.html { render json: @sd_picod }
      format.json { render json: @sd_picod }
      format.xml { render xml: @sd_picod }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

end
