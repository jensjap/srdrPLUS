class ProjectDashboardController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[kpis]
  before_action :set_project, only: %i[citation_lifecycle_management kpis]
  after_action :verify_authorized

  def citation_lifecycle_management
    authorize(@project, policy_class: ProjectDashboardPolicy)
    @nav_buttons.push('project_info_dropdown', 'lifecycle_management', 'my_projects')
    respond_to do |format|
      format.html
      format.json do
        @query = params[:query].present? ? params[:query] : '*'
        @order_by = params[:order_by]
        @sort = params[:sort].present? ? params[:sort] : nil
        @page = params[:page].present? ? params[:page].to_i : 1
        per_page = 100
        order = @order_by.present? ? { @order_by => @sort } : {}
        @citations_projects =
          CitationsProject
          .search(@query,
                  where: { project_id: @project.id },
                  limit: per_page, offset: per_page * (@page - 1), order:, load: false)
        @total_pages = (@citations_projects.total_count / per_page) + 1
      end
    end
  end

  def kpis
    authorize(@project, policy_class: ProjectDashboardPolicy)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end
end
