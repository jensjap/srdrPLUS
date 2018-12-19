class ScreeningOptionsController < ApplicationController
  add_breadcrumb 'my projects', :projects_path

  before_action :set_project, only: [:index]

  def index
    add_breadcrumb 'edit project', edit_project_path(@project)
    add_breadcrumb 'screening options',    :project_screening_options_path
  end

  private

    #a helper method that sets the current citation from id to be used with callbacks
    def set_project
      @project = Project.find(params[:project_id])
    end
end
