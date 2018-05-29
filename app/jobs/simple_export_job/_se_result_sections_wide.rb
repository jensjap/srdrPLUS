require 'simple_export_job/sheet_info'

def build_result_sections_wide(p, project, highlight, wrap)
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a result section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 3

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) } - wide") do |sheet|

          # For each sheet we create a SheetInfo object.
          sheet_info = SheetInfo.new

          # Every row represents an extraction.
          project.extractions.each do |extraction|

            #!!! We can probably use scope for this.
            # Find all eefps that are Outcomes.
            efps_outcomes = efp.extraction_forms_projects_sections
              .joins(:section)
              .where(sections: { name: 'Outcomes' })
            eefps_outcomes = ExtractionsExtractionFormsProjectsSection.where(
              extraction: extraction,
              extraction_forms_projects_section: efps_outcomes)

            # Find all eefps that are Arms.
            efps_arms = efp.extraction_forms_projects_sections
              .joins(:section)
              .where(sections: { name: 'Arms' })
            eefps_arms = ExtractionsExtractionFormsProjectsSection.where(
              extraction: extraction,
              extraction_forms_projects_section: efps_arms)

            # Create base for extraction information.
            sheet_info.new_extraction_info(extraction)

            # Collect basic information about the extraction.
            sheet_info.set_extraction_info(
              extraction_id: extraction.id,
              username: extraction.projects_users_role.projects_user.user.profile.username,
              citation_id: extraction.citations_project.citation.id,
              citation_name: extraction.citations_project.citation.name,
              refman: extraction.citations_project.citation.refman,
              pmid: extraction.citations_project.citation.pmid)

            eefps = efps.extractions_extraction_forms_projects_sections.find_by(
              extraction: extraction,
              extraction_forms_projects_section: efps)

            # Each Outcome has multiple Populations, which in turn has 4 result
            # statistic quadrants . We iterate over each of the results statistic
            # quadrants:
            #   - (q1) Descriptive (DSC)
            #   - (q2) Between Arm Comparison (BAC)
            #   - (q3) Within Arm Comparison (WAC)
            #   - (q4) Net Change (NET)
            # Each quadrant has rows and columns and within each row/column cell
            # there's a list of measures.
            #
            # Total number of columns in export =
            #   Outcomes x
            #   Populations x
            #   ( (Timepoints x Arms x q1-Measures) +
            #     (Timepoints x BAC  x q2-Measures) +
            #     (   WAC     x Arms x q3-Measures) +
            #     (   WAC     x BAC  x q4-Measures) )
            #
            # To uniquely identify a data value we therefore need:
            # OutcomeID, PopulationID, RowID, ColumnID, MeasureID

            eefps_outcomes.each do |eefps_outcome|

              eefps_outcome.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_outcome|  # Outcome.
                eefpst1_outcome.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|  # Population
                  eefpst1r.result_statistic_sections.each do |result_statistic_section|  # Result Statistic Section Quadrant

                    case result_statistic_section.result_statistic_section_type_id

                    when 1  # Descriptive Statistics - Timepoint x Arm x q1-Measure.
                      eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint
                        eefps_arms.each do |eefps_arm|  # Arm
                          eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                            result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q1-Measure

                              sheet_info.add_rssm(
                                extraction_id: extraction.id,
                                section_name: efps.section.name.singularize,
                                outcome_id: eefpst1_outcome.type1.id,
                                outcome_name: eefpst1_outcome.type1.name,
                                outcome_description: eefpst1_outcome.type1.description,
                                population_id: eefpst1r.population_name.id,
                                population_name: eefpst1r.population_name.name,
                                population_description: eefpst1r.population_name.description,
                                result_statistic_section_id: result_statistic_section.result_statistic_section_type.id,
                                result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                                timepoint_id: eefpst1rc.timepoint_name.id,
                                timepoint_name: eefpst1rc.timepoint_name.name,
                                timepoint_unit: eefpst1rc.timepoint_name.unit,
                                arm_id: eefpst1_arm.type1.id,
                                arm_name: eefpst1_arm.type1.name,
                                arm_description: eefpst1_arm.type1.description,
                                measure_id: rssm.measure.id,
                                measure_name: rssm.measure.name,
                                rssm_values: eefpst1_arm.tps_arms_rssms_values(eefpst1rc.id, rssm))

                            end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q1-Measure
                          end  # eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                        end  # eefps_arms.each do |eefps_arm|
                      end  # eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint

                    when 2  # Between Arm Comparisons - Timepoint x BAC x q2-Measure.
                      eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint
                        result_statistic_section.comparisons.each do |bac|
                          result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q2-Measure

                            sheet_info.add_rssm(
                              extraction_id: extraction.id,
                              section_name: efps.section.name.singularize,
                              outcome_id: eefpst1_outcome.type1.id,
                              outcome_name: eefpst1_outcome.type1.name,
                              outcome_description: eefpst1_outcome.type1.description,
                              population_id: eefpst1r.population_name.id,
                              population_name: eefpst1r.population_name.name,
                              population_description: eefpst1r.population_name.description,
                              result_statistic_section_id: result_statistic_section.result_statistic_section_type.id,
                              result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                              timepoint_id: eefpst1rc.timepoint_name.id,
                              timepoint_name: eefpst1rc.timepoint_name.name,
                              timepoint_unit: eefpst1rc.timepoint_name.unit,
                              comparison_id: bac.id,
                              measure_id: rssm.measure.id,
                              measure_name: rssm.measure.name,
                              rssm_values: bac.tps_comparisons_rssms_values(eefpst1rc.id, rssm))

                          end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q2-Measure
                        end  # result_statistic_section.comparisons.each do |bac|
                      end  # eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|  # Timepoint

                    when 3  # Within Arm Comparisons - WAC x Arm x q3-Measure.
                      result_statistic_section.comparisons.each do |wac|
                        eefps_arms.each do |eefps_arm|  # Arm
                          eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                            result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q3-Measure

                              sheet_info.add_rssm(
                                extraction_id: extraction.id,
                                section_name: efps.section.name.singularize,
                                outcome_id: eefpst1_outcome.type1.id,
                                outcome_name: eefpst1_outcome.type1.name,
                                outcome_description: eefpst1_outcome.type1.description,
                                population_id: eefpst1r.population_name.id,
                                population_name: eefpst1r.population_name.name,
                                population_description: eefpst1r.population_name.description,
                                result_statistic_section_id: result_statistic_section.result_statistic_section_type.id,
                                result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                                wac_id: wac.id,
                                arm_id: eefpst1_arm.type1.id,
                                arm_name: eefpst1_arm.type1.name,
                                arm_description: eefpst1_arm.type1.description,
                                measure_id: rssm.measure.id,
                                measure_name: rssm.measure.name,
                                rssm_values: wac.comparisons_arms_rssms_values(eefpst1_arm.id, rssm))

                            end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q3-Measure
                          end  # eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                        end  # eefps_arms.each do |eefps_arm|  # Arm
                      end  # result_statistic_section.comparisons.each do |wac|

                    when 4  # Net Change - WAC x BAC x q4-Measure.
                      wac_section = result_statistic_section.population.within_arm_comparisons_section
                      bac_section = result_statistic_section.population.between_arm_comparisons_section
                      wac_section.comparisons.each do |wac|
                        bac_section.comparisons.each do |bac|
                          result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q4-Measure

                            sheet_info.add_rssm(
                              extraction_id: extraction.id,
                              section_name: efps.section.name.singularize,
                              outcome_id: eefpst1_outcome.type1.id,
                              outcome_name: eefpst1_outcome.type1.name,
                              outcome_description: eefpst1_outcome.type1.description,
                              population_id: eefpst1r.population_name.id,
                              population_name: eefpst1r.population_name.name,
                              population_description: eefpst1r.population_name.description,
                              result_statistic_section_id: result_statistic_section.result_statistic_section_type.id,
                              result_statistic_section_type_name: result_statistic_section.result_statistic_section_type.name,
                              wac_id: wac.id,
                              bac_id: bac.id,
                              measure_id: rssm.measure.id,
                              measure_name: rssm.measure.name,
                              rssm_values: wac.wacs_bacs_rssms_values(bac.id, rssm))

                          end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q4-Measure
                        end  # bac_section.comparisons.each do |bac|
                      end  # wac_section.comparisons.each do |wac|
                    end  # case result_statistic_section.result_statistic_section_type_id
                  end  # eefpst1r.result_statistic_sections.each do |result_statistic_section|  # Result Statistic Section Quadrant
                end  # eefpst1_outcome.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|  # Population
              end  # eefps_outcome.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_outcome|  # Outcome.
            end  # eefps_outcomes.each do |eefps_outcome|
          end  # project.extractions.each do |extraction|
          byebug
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) } - wide") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 3
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
