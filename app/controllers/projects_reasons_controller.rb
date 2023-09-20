class ProjectsReasonsController < ApplicationController
  def create
    reason = Reason.find_or_create_by(name: params[:name])
    projects_reason = ProjectsReason.find_or_create_by(project_id: params[:project_id], reason:,
                                                       screening_type: ProjectsReason::ABSTRACT)
    render json: projects_reason, status: 200
  end

  def update
    projects_reason = ProjectsReason.find(params[:id])
    updated_reason = Reason.find_or_create_by!(name: params[:newCustomValue])
    AbstractScreeningResultsReason
      .where(
        reason: projects_reason.reason,
        abstract_screening_result: projects_reason.project.abstract_screening_results
      )
      .each do |asrr|
        if AbstractScreeningResultsReason.find_by(abstract_screening_result: asrr.abstract_screening_result,
                                                  reason: updated_reason)
          asrr.destroy
        else
          asrr.update(reason: updated_reason)
        end
      end
    projects_reason.update(reason: updated_reason)
    render json: projects_reason, status: 200
  end

  def destroy
    projects_reason = ProjectsReason.find(params[:id])
    projects_reason.destroy
    render json: projects_reason, status: 200
  end
end
