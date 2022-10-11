class ScreeningOptionsController < ApplicationController
  before_action :set_project, only: [:index]

  def index; end

  private

  # a helper method that sets the current citation from id to be used with callbacks
  def set_project
    @project = Project.find(params[:project_id])
  end
end
