class FulltextScreeningsController < ApplicationController
  add_breadcrumb 'my projects', :projects_path
  before_action :set_project, only: %i[index]
  after_action :verify_authorized

  def index
    authorize(@project, policy_class: AbstractScreeningPolicy)
    @abstract_screenings =
      policy_scope(@project,
                   policy_scope_class: AbstractScreeningPolicy::Scope)
    @fulltext_screenings =
      @project
      .fulltext_screenings.order(id: :desc)
      .page(params[:page])
      .per(5)
  end

  private

  def set_project
    @project = Project.includes(citations_projects: :citation).find(params[:project_id])
  end
end
