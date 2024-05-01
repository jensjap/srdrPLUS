class Api::V3::SdSearchStrategiesController < Api::V3::BaseController

  def show
    @sd_search_strategy = SdMetaDataSupplyingService.new.get_sd_search_strategy_by_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @sd_search_strategy }
      format.fhir_json { render json: @sd_search_strategy }
      format.html { render json: @sd_search_strategy }
      format.json { render json: @sd_search_strategy }
      format.xml { render xml: @sd_search_strategy }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

end
