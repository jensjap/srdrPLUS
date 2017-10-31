class Api::V1::ExtractionsController < Api::V1::BaseController
  before_action :set_project, only: [:index]

  def index
    #respond_with Extraction.all
    respond_with @project.extractions
  end

  private

    def set_project
      @project = Project.find(params[:project_id])
    end
end
