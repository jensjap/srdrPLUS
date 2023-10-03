class ProjectsTagsController < ApplicationController
  def index
    render json: ProjectsTag.tags_object(Project.find(params[:project_id]), params[:screening_type]), status: 200
  end

  def create
    authorize(Project.find(params[:project_id]), policy_class: ProjectsTagPolicy)
    tag = Tag.find_or_create_by(name: params[:name])
    projects_tag = ProjectsTag.find_or_create_by(project_id: params[:project_id], tag:,
                                                 screening_type: params[:screening_type])
    render json: projects_tag, status: 200
  end

  def update
    projects_tag = ProjectsTag.find(params[:id])
    authorize(projects_tag.project, policy_class: ProjectsTagPolicy)
    updated_tag = Tag.find_or_create_by!(name: params[:newCustomValue])
    AbstractScreeningResultsTag
      .where(
        tag: projects_tag.tag,
        abstract_screening_result: projects_tag.project.abstract_screening_results
      )
      .each do |asrt|
        if AbstractScreeningResultsTag.find_by(abstract_screening_result: asrt.abstract_screening_result,
                                               tag: updated_tag)
          asrt.destroy
        else
          asrt.update(tag: updated_tag)
        end
      end
    projects_tag.update(tag: updated_tag)
    render json: projects_tag, status: 200
  end

  def destroy
    projects_tag = ProjectsTag.find(params[:id])
    authorize(projects_tag.project, policy_class: ProjectsTagPolicy)
    projects_tag.destroy
    render json: projects_tag, status: 200
  end
end
