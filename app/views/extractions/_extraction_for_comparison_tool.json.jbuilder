json.extract! extraction, :project_id, :citations_project_id

json.sections extraction.extractions_extraction_forms_projects_sections.order(:extraction_forms_projects_section_id) do |eefps|
  # Switch on ExtractionFormsProjectsSectionType.
  case eefps.extraction_forms_projects_section.extraction_forms_projects_section_type_id
  when 1
    json.name eefps.extraction_forms_projects_section.section.name.to_s
    json.type1s eefps.extractions_extraction_forms_projects_sections_type1s.order(:type1_id) do |eefpst1|
      json.id eefpst1.type1.id
      json.name eefpst1.type1.name.to_s
      json.description eefpst1.type1.description.to_s
      json.populations eefpst1.extractions_extraction_forms_projects_sections_type1_rows do |eefpst1r|
        json.id eefpst1r.population_name.id
        json.name eefpst1r.population_name.name
        json.description eefpst1r.population_name.description
        json.timepoints eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns do |eefpst1rc|
          json.id eefpst1rc.timepoint_name.id
          json.name eefpst1rc.timepoint_name.name
          json.unit eefpst1rc.timepoint_name.unit
        end
      end
    end

  when 2
    json.name eefps.extraction_forms_projects_section.section.name.to_s
    json.questions eefps.extraction_forms_projects_section.questions do |q|
      q.question_rows.each do |qr|
        qr.question_row_columns.each do |qrc|
          qrc.question_row_column_fields.each do |qrcf|
            # If this section is linked we have to iterate through each occurrence of
            # type1 via eefps.extractions_extraction_forms_projects_sections_type1s.
            # Otherwise we proceed with eefpst1s set to a custom Struct that responds
            # to :id, type1: :id.
            eefpst1s = eefps.link_to_type1.present? ?
              eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s :
              [Struct.new(:id, :type1).new(nil, Struct.new(:id).new(nil))]
            json.type1s eefpst1s do |eefpst1|
              json.id eefpst1.type1.id
              json.answers eefps.eefps_qrfc_values(eefpst1.id, qrc).to_s
            end
          end
        end
      end
    end

  when 3
    json.name eefps.extraction_forms_projects_section.section.name.to_s
    json.outcomes ExtractionsExtractionFormsProjectsSectionsType1
      .by_section_name_and_extraction_id_and_extraction_forms_project_id(
        'Outcomes',
        eefps.extraction.id,
        eefps.extraction_forms_projects_section.extraction_forms_project.id) do |outcome|
          json.name outcome.type1.name.to_s
          json.description outcome.type1.description.to_s
          json.populations outcome.extractions_extraction_forms_projects_sections_type1_rows do |population|
            json.name population.population_name.name.to_s
            json.description population.population_name.description.to_s
            json.result_statistic_sections population.result_statistic_sections do |rss|
              json.name rss.result_statistic_section_type.name.to_s
              arms = ExtractionsExtractionFormsProjectsSectionsType1.
                by_section_name_and_extraction_id_and_extraction_forms_project_id(
                  'Arms',
                  rss.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction.id,
                  rss.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.extraction_forms_project.id)
              case rss.result_statistic_section_type_id
              when 1
                json.timepoints population.extractions_extraction_forms_projects_sections_type1_row_columns do |timepoint|
                  json.name timepoint.timepoint_name.name.to_s
                  json.unit timepoint.timepoint_name.unit.to_s
                  json.arms arms do |arm|
                    json.name arm.type1.name.to_s
                    json.description arm.type1.description.to_s
                    json.measures rss.result_statistic_sections_measures do |rssm|
                      json.name rssm.measure.name.to_s
                      json.value arm.tps_arms_rssms_values(timepoint.id, rssm).to_s
                    end
                  end
                end
              when 2
                json.timepoints population.extractions_extraction_forms_projects_sections_type1_row_columns do |timepoint|
                  json.name timepoint.timepoint_name.name.to_s
                  json.unit timepoint.timepoint_name.unit.to_s
                  json.comparisons rss.comparisons do |bac|
                    json.name bac.pretty_print_export_header
                    json.comparison_type :bac
                    json.measures rss.result_statistic_sections_measures do |rssm|
                      json.name rssm.measure.name.to_s
                      json.value bac.tps_comparisons_rssms_values(timepoint.id, rssm).to_s
                    end
                  end
                end
              when 3
                json.comparisons rss.comparisons do |wac|
                  json.name wac.pretty_print_export_header
                  json.comparison_type :wac
                  json.arms arms do |arm|
                    json.name arm.type1.name.to_s
                    json.description arm.type1.description.to_s
                    json.measures rss.result_statistic_sections_measures do |rssm|
                      json.name rssm.measure.name.to_s
                      json.value wac.comparisons_arms_rssms_values(arm.id, rssm)
                    end
                  end
                end
              when 4
                json.comparisons rss.population.within_arm_comparisons_section.comparisons do |wac|
                  json.name wac.pretty_print_export_header
                  json.comparison_type :wac
                  json.comparisons rss.population.between_arm_comparisons_section.comparisons do |bac|
                    json.name wac.pretty_print_export_header
                    json.comparison_type :bac
                    json.measures rss.result_statistic_sections_measures do |rssm|
                      json.name rssm.measure.name.to_s
                      json.value wac.wacs_bacs_rssms_values(bac.id, rssm)
                    end
                  end
                end
              else
                raise RuntimeError, 'Result Statistic Section is of Unknown Type'
              end
            end
          end
        end

  else
    raise RuntimeError, 'Unknown ExtractionFormsProjectsSectionType'
  end
end
