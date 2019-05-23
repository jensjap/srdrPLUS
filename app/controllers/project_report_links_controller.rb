class ProjectReportLinksController < ApplicationController
  def index
    @sd_meta_data = SdMetaDatum.includes(project: { key_questions_projects: :key_question }).all
  end

  def new_query_form
    meta_datum_id = params[:project_report_link_id]
    project = SdMetaDatum.find(meta_datum_id).project
    if project
      @groups = project.
        questions.
        joins(:key_questions_projects).
        where(key_questions_projects: { id: new_query_params[:kqp_ids] }).
        group_by { |question| question.extraction_forms_projects_section.section }
    end

    @results_groups = get_rssm_groups(project.id)
  end

  private

    def get_rssm_groups(project_id)
      rssms = ResultStatisticSectionsMeasure.
        joins(result_statistic_section: {
          population: {
            extractions_extraction_forms_projects_sections_type1: {
              extractions_extraction_forms_projects_section: {
                extraction: :project
              }
            }
          }
        }).
        where(result_statistic_section: {
          population: {
            extractions_extraction_forms_projects_sections_type1: {
              extractions_extraction_forms_projects_section: {
                extractions: { project_id: project_id }
              }
            }
          }
        }).
        uniq(&:measure_id)
      rssms.group_by { |rssm| rssm.result_statistic_section.result_statistic_section_type }
    end

    def new_query_params
      params[:sd_meta_datum] ?
        params.require(:sd_meta_datum).permit(kqp_ids: []) :
        { kqp_ids: [] }
    end
end
