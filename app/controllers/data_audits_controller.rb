class DataAuditsController < ApplicationController
  def index
    project_ids = params[:query]
                    .split(',')
                    .map(&:strip)
                    .map(&:to_i)
                    .delete_if { |x| x.eql?(0) } if params[:query]
    @projects = Project.where(id: project_ids)
  end
end
