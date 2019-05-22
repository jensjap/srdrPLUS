class ProjectReportLinksController < ApplicationController
  def index
    @sd_meta_data = SdMetaDatum.includes(project: { key_questions_projects: :key_question }).all
  end

  def new_query_form
    @sd_meta_datum = SdMetaDatum.find(params[:project_report_link_id])
    @project = @sd_meta_datum.project
    ids = [1,2,3]
    if @project
      @groups = @project.questions.joins(:key_questions_projects).where(key_questions_projects: { id: new_query_params[:kqp_ids] }).group_by { |question| question.extraction_forms_projects_section.section }
    end
  end

  private

    def new_query_params
      params.require(:sd_meta_datum).permit(kqp_ids: [])
    end
end
