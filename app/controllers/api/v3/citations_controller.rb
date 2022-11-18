class Api::V3::CitationsController < ApplicationController
  # TODO implement search parms logic

  before_action :set_project, only: [:index]
#  before_action :set_citation, only: [:show]

  def index
    @citations = CitationSupplyingService.new.find_by_project_id(@project.id)
    respond_to do |format|
      format.fhir_xml { render xml: @citations }
      format.fhir_json { render json: @citations }
      format.html { render json: @citations }
      format.json { render json: @citations }
      format.xml { render xml: @citations }
      format.all { render :text => "Only HTML, JSON and XML are currently supported", status: 406 }
    end
  end

  def show
    @citation = CitationSupplyingService.new.find_by_citation_id(params[:id])
    respond_to do |format|
      format.fhir_xml { render xml: @citation }
      format.fhir_json { render json: @citation }
      format.html { render json: @citation }
      format.json { render json: @citation }
      format.xml { render xml: @citation }
      format.all { render :text => "Only HTML, JSON and XML are currently supported", status: 406 }
    end
  end

  private

#    def validate_object(object)
#      CitationSupplyingService.validate(object)
#    end

#    def set_citation
#      @raw_citation = Citation.find(params[:id])
#    end
    
    def set_project
      @project = Project.find(params[:project_id])
    end

#    def citation_params
#      params.permit(:project_id, :id)
#    end

end
