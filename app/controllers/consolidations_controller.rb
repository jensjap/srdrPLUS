class ConsolidationsController < ApplicationController
  before_action :set_project, only: %i[index create]

  def index
    cookies[:consolidation_beta] = true if params[:consolidation_beta_opt_in]
    cookies.delete(:consolidation_beta) if params[:consolidation_beta_opt_out]

    return redirect_to "/projects/#{@project.id}/extractions/comparison_tool" unless cookies[:consolidation_beta]

    authorize(@project, policy_class: ConsolidationPolicy)
    @nav_buttons.push('comparison_tool', 'my_projects')
    respond_to do |format|
      format.json do
        return render json: ConsolidationService.project_citations_grouping_hash(@project)
      end
      format.html
    end
  end

  def create
    render json: @project.consolidated_extraction(params[:citations_project_id], current_user.id)
  end

  def show
    @citations_project = CitationsProject.find(params[:citations_project_id])
    @project = @citations_project.project
    authorize(@project, policy_class: ConsolidationPolicy)
    respond_to do |format|
      format.html do
        @nav_buttons.push('comparison_tool', 'my_projects')
      end
      format.json do
        efps =
          ExtractionFormsProjectsSection.find_by(id: params[:efps_id]) ||
          ExtractionFormsProject.find_by(project: @project).extraction_forms_projects_sections.first
        return render json: {
          efps_sections: ConsolidationService.efps_sections(@project),
          mh: ConsolidationService.efps(efps, @citations_project)
        }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
