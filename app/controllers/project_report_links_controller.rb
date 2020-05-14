class ProjectReportLinksController < ApplicationController
  add_breadcrumb 'my project-report links',  :project_report_links_url

  MEASURES_ORDER = [
    "Descriptive Statistics",
    "Between Arm Comparisons",
    "Within Arm Comparisons",
    "NET Change",
    "Diagnostic Test Descriptive Statistics",
    "Diagnostic Test -placeholder for AUC and Q*-",
    "Diagnostic Test 2x2 Table",
    "Diagnostic Test Test Accuracy Metrics"].freeze

  def index
    @sd_meta_data = policy_scope(SdMetaDatum).
      includes(project: { key_questions_projects: :key_question }).
      #where(state: 'COMPLETED')
      where(section_flag_0: true,
            section_flag_1: true,
            section_flag_2: true,
            section_flag_3: true,
            section_flag_4: true,
            section_flag_5: true,
            section_flag_6: true)
  end

  def options_form
    sd_meta_data_query = ( params[:sd_meta_data_query_id].present? ? SdMetaDataQuery.find(params[:sd_meta_data_query_id]) : nil )
    loaded_params = ( sd_meta_data_query ? sd_meta_data_query.query_hash.symbolize_keys : params )
    create_common_instance_variables loaded_params
    @columns = loaded_params[:columns] || {}
  end

  def new_query_form
    create_common_instance_variables params
    add_breadcrumb 'new query',  project_report_link_new_query_form_url(@sd_meta_datum)

    @projects_user = ProjectsUser.find_by user: current_user, project: @project
    @sd_meta_data_queries = @sd_meta_datum.sd_meta_data_queries.where( projects_user: @projects_user )
  end

  private

    def create_common_instance_variables loaded_params
      meta_datum_id = loaded_params[:project_report_link_id]
      @sd_meta_datum = SdMetaDatum.find(meta_datum_id)
      @project = @sd_meta_datum.project
      kqp_ids = loaded_params[:kqp_ids] || @project.key_questions_projects.map(&:id)
      @key_question_project_ids = kqp_ids ? kqp_ids.join(",") : ""
      if @project
        groups_hash = @project.
          questions.
          joins(:key_questions_projects).
          where(key_questions_projects: { id: kqp_ids }).
          uniq.
          group_by { |question| question.extraction_forms_projects_section.section }

        @groups = order_groups_hash(groups_hash)
      end

      @included_type1s = @project.
        extraction_forms_projects.
        where(extraction_forms_project_type_id: [1, 2]).
        first.
        extraction_forms_projects_sections.
        where(extraction_forms_projects_section_type_id: 1).
        map do |efps|
          { section_name:  efps.section.name,
            extraction_forms_projects_section_id: efps.id,
            export_ids: ExtractionsExtractionFormsProjectsSectionsType1.
              joins(extractions_extraction_forms_projects_section: :extraction_forms_projects_section).
              where(extractions_extraction_forms_projects_sections: { extraction_forms_projects_section_id: efps.id }).
              map { |eefpst| {
                type1_id: eefpst.type1_id,
                name_and_description: eefpst.type1.name_and_description,
                type1_type: eefpst.try(:type1_type).try(:name),
              } }.
              uniq
          }
        end
      @results_groups = get_rssm_groups(@project.id, loaded_params[:type1s])
      @key_questions_projects = @project.key_questions_projects
    end

    def order_groups_hash(hash)
      ordered_2d = []
      hash.each do |key, values|
        index = values.first.extraction_forms_projects_section.ordering.position
        ordered_2d[index] = [key, values]
      end
      ordered_2d.compact
    end

    def get_rssm_groups(project_id, type1s)
      # TODO: The logic here is wrong. This would cause problem if there are arms/outcomes with the same spelling -Birol
      if type1s.present?
        eefpst1 = {
          type1_id: type1s.values.flatten,
            extractions_extraction_forms_projects_sections: {
              extractions: { project_id: project_id },
              extraction_forms_projects_section_id: type1s.keys
            }
          }
      else
        eefpst1 = {
          extractions_extraction_forms_projects_sections: {
            extractions: { project_id: project_id }
          }
        }
      end

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
            extractions_extraction_forms_projects_sections_type1s: eefpst1
          }
        }).
        uniq(&:measure_id)
      rssms = rssms.group_by { |rssm| rssm.result_statistic_section.result_statistic_section_type }
      rssms.each do |key, values|
        values_with_efps_id = values.map { |rssm| { rssm: rssm, efps_id: rssm.result_statistic_section.population.extractions_extraction_forms_projects_section.extraction_forms_projects_section_id } }
        ordered_2d[MEASURES_ORDER.index(key.name)] = [key, values_with_efps_id]
      end
      ordered_2d.compact
    end
end
