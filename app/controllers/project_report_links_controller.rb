class ProjectReportLinksController < ApplicationController
  MEASURES_ORDER = ["Descriptive Statistics", "Between Arm Comparisons", "Within Arm Comparisons", "NET Change"].freeze

  def index
    @sd_meta_data = SdMetaDatum.includes(project: { key_questions_projects: :key_question }).where(state: 'COMPLETED')
  end

  def new_query_form
    meta_datum_id = params[:project_report_link_id]
    @key_question_project_ids = new_query_params[:kqp_ids].join(",")
    @project = SdMetaDatum.find(meta_datum_id).project
    if @project
      groups_hash = @project.
        questions.
        joins(:key_questions_projects).
        where(key_questions_projects: { id: new_query_params[:kqp_ids] }).
        group_by { |question| question.extraction_forms_projects_section.section }

      @groups = order_groups_hash(groups_hash)
    end

    @results_groups = get_rssm_groups(@project.id)
  end

  private

    def order_groups_hash(hash)
      ordered_2d = []
      hash.each do |key, values|
        index = values.first.extraction_forms_projects_section.ordering.position
        ordered_2d[index] = [key, values]
      end
      ordered_2d.compact
    end

    def get_rssm_groups(project_id)
      ordered_2d = []
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
      rssms = rssms.group_by { |rssm| rssm.result_statistic_section.result_statistic_section_type }
      rssms.each do |key, values|
        ordered_2d[MEASURES_ORDER.index(key.name)] = [key, values]
      end
      ordered_2d
    end

    def new_query_params
      params[:sd_meta_datum] ?
        params.require(:sd_meta_datum).permit(kqp_ids: []) :
        { kqp_ids: [] }
    end
end
