class ConsolidationsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @nav_buttons.push('comparison_tool')
    respond_to do |format|
      format.json do
        return render json: ConsolidationService.project_citations_grouping_hash(@project)
      end
      format.html
    end
  end
end
