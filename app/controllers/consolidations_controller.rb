class ConsolidationsController < ApplicationController
  before_action :set_project, only: %i[index create]

  def index
    cookies[:consolidation_beta] = true if params[:consolidation_beta_opt_in]
    cookies.delete(:consolidation_beta) if params[:consolidation_beta_opt_out]

    unless cookies[:consolidation_beta]
      return redirect_to("/projects/#{@project.id}/extractions/comparison_tool",
                         status: 303)
    end

    authorize(@project, policy_class: ConsolidationPolicy)
    @nav_buttons.push('comparison_tool', 'my_projects')
    respond_to do |format|
      format.json
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
        mh = ConsolidationService.efps(efps, @citations_project)
        suggestions = ConsolidationService.suggestions(mh[:current_citations_project][:current_section_eefpss].last['id'])
        result_statistic_section_type = if efps.extraction_forms_project.extraction_forms_project_type_id == 2
                                          5
                                        else
                                          (params[:result_statistic_section_type_id] || 1).to_i
                                        end
        results = ConsolidationService.results(efps, @citations_project, result_statistic_section_type)
        return render json: {
          efps_sections: ConsolidationService.efps_sections(@project),
          mh:,
          suggestions:,
          master_template: results[:master_template],
          results_lookup: results[:results_lookup],
          dimensions_lookup: results[:dimensions_lookup],
          rss_lookup: results[:rss_lookup],
          comparables: results[:comparables],
          extraction_ids: results[:extraction_ids],
          result_statistic_section_type_id: results[:result_statistic_section_type_id]
        }
      end
    end
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
