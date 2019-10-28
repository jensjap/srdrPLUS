class ProjectReportLinksController < ApplicationController
  MEASURES_ORDER = [
    "Descriptive Statistics",
    "Between Arm Comparisons",
    "Within Arm Comparisons",
    "NET Change"].freeze

  def index
    @sd_meta_data = SdMetaDatum.
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
    create_common_instance_variables
  end

  def new_query_form
    create_common_instance_variables
  end

  private

    def create_common_instance_variables
      meta_datum_id = params[:project_report_link_id]
      @sd_meta_datum = SdMetaDatum.find(meta_datum_id)
      @project = @sd_meta_datum.project
      kqp_ids = params[:kqp_ids] || @project.key_questions_projects.map(&:id)
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
      @results_groups = get_rssm_groups(@project.id)
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

    def get_rssm_groups(project_id)
      if params[:type1s].present?
        extractions_extraction_forms_projects_sections_type1 = {
          type1_id: params[:type1s].values,
          extractions_extraction_forms_projects_sections: {
            extractions: { project_id: project_id },
            extraction_forms_projects_section_id: params[:type1s].keys,
          }
        }
      else
        extractions_extraction_forms_projects_sections_type1 = {
          extractions_extraction_forms_projects_sections: {
            extractions: { project_id: project_id },
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
            extractions_extraction_forms_projects_sections_type1s: extractions_extraction_forms_projects_sections_type1
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
