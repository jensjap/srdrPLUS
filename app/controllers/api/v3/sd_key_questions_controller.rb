class Api::V3::SdKeyQuestionsController < Api::V3::BaseController

  def show
    @sd_key_question = SdMetaDataSupplyingService.new.get_sd_key_question_by_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @sd_key_question }
      format.fhir_json { render json: @sd_key_question }
      format.html { render json: @sd_key_question }
      format.json { render json: @sd_key_question }
      format.xml { render xml: @sd_key_question }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

end
