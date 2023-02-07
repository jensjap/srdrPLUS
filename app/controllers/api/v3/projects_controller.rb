class Api::V3::ProjectsController < Api::V3::BaseController

  def show
    @project = AllResourceSupplyingService.new.find_by_project_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @project }
      format.fhir_json { render json: @project }
      format.html { render json: @project }
      format.json { render json: @project }
      format.xml { render xml: @project }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

end
