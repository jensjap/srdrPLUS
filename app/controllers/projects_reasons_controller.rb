class ProjectsReasonsController < ApplicationController
  def index
    render json: ProjectsReason.reasons_object(Project.find(params[:project_id]), params[:screening_type]), status: 200
  end

  def create
    authorize(Project.find(params[:project_id]), policy_class: ProjectsReasonPolicy)
    reason = Reason.find_or_create_by(name: params[:name])
    projects_reason = ProjectsReason.find_or_create_by(project_id: params[:project_id], reason:,
                                                       screening_type: params[:screening_type])
    render json: projects_reason, status: 200
  end

  def update
    projects_reason = ProjectsReason.find(params[:id])
    authorize(projects_reason.project, policy_class: ProjectsReasonPolicy)
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
    authorize(projects_reason.project, policy_class: ProjectsReasonPolicy)
    projects_reason.destroy
    render json: projects_reason, status: 200
  end

  def get_default_rejection_reasons
    screening_type = params[:screening_type]
    file_path = case screening_type
                when 'abstract'
                  'config/screening/as_default_rejection_reason.yml'
                when 'fulltext'
                  'config/screening/fs_default_rejection_reason.yml'
                else
                  return render json: { error: 'Invalid screening type' }, status: :bad_request
                end

    yaml_data = YAML.load_file(file_path)
    reasons = yaml_data['rejection_reasons'].values.flatten.map { |r| r['description'] }
    render json: reasons
  end
end
