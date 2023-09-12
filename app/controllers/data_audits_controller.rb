class DataAuditsController < ApplicationController
  before_action :check_admin
  before_action :set_project, only: [:create]
  before_action :set_data_audit, only: [:update]

  def index
    if params[:query]
      project_ids = params[:query]
                    .split(',')
                    .map(&:strip)
                    .map(&:to_i)
                    .delete_if { |x| x.eql?(0) }
    end
    @projects = Project.where(id: project_ids)
    @projects.each do |project|
      project.build_data_audit unless project.data_audit
    end
  end

  def create
    @project.build_data_audit(data_audit_params)
    respond_to do |format|
      if @project.data_audit.save
        format.js { @info = [true, 'Success!', 'green'] }
      else
        format.js { @info = [false, 'Error!', 'red'] }
      end
    end
  end

  def update
    @data_audit.update(data_audit_params)
    respond_to do |format|
      if @data_audit.save
        format.js { @info = [true, 'Success!', 'green'] }
      else
        format.js { @info = [false, 'Error!', 'red'] }
      end
    end
  end

  private

  def check_admin
    return if current_user.admin?

    flash[:error] = 'You are not authorized to perform this action.'
    redirect_to('/', status: 303)
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_data_audit
    @data_audit = DataAudit.find(params[:id])
  end

  def data_audit_params
    params
      .require(:data_audit)
      .permit(
        :epc_source,
        :epc_name,
        :non_epc_name,
        :capture_method,
        :pct_extractions_with_unstructured_data,
        :distiller_w_results,
        :single_multiple_w_consolidation,
        :notes
      )
  end
end
