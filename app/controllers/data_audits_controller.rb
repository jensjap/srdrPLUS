class DataAuditsController < ApplicationController
  before_action :set_project, only: [:create]
  def index
    project_ids = params[:query]
                    .split(',')
                    .map(&:strip)
                    .map(&:to_i)
                    .delete_if { |x| x.eql?(0) } if params[:query]
    @projects = Project.where(id: project_ids)
    @projects.each do |project|
      project.build_data_audit
    end
  end

  def create
debugger
  end

  private
    def set_project
debugger
    end
end
