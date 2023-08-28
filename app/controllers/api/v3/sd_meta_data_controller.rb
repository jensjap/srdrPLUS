class Api::V3::SdMetaDataController < Api::V3::BaseController
  before_action :set_project, only: [:index]

  def index
    authorize(@project, policy_class: SdMetaDatumPolicy)
    @sd_meta_datum = SdMetaDataSupplyingService.new.find_by_project_id(@project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @sd_meta_datum }
      format.fhir_json { render json: @sd_meta_datum }
      format.html { render json: @sd_meta_datum }
      format.json { render json: @sd_meta_datum }
      format.xml { render xml: @sd_meta_datum }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  def show
    @sd_meta_data = SdMetaDataSupplyingService.new.find_by_sd_meta_data_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @sd_meta_data }
      format.fhir_json { render json: @sd_meta_data }
      format.html { render json: @sd_meta_data }
      format.json { render json: @sd_meta_data }
      format.xml { render xml: @sd_meta_data }
      format.all { render text: 'Only HTML, JSON and XML are currently supported', status: 406 }
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
