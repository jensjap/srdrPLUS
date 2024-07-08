class Api::V3::UsersController < Api::V3::BaseController

  def show
    @user = UserSupplyingService.new.find_by_user_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @user }
      format.fhir_json { render json: @user }
      format.html { render json: @user }
      format.json { render json: @user }
      format.xml { render xml: @user }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

end
