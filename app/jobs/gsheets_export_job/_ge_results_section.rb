require 'simple_export_job/sheet_info'

def build_result_sections_wide(p, project)
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a result section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 3

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(30) }") do |sheet|

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
                username: extraction.username,
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
                                  row_id: eefpst1rc.timepoint_name.id,             # timepoint_id       Note: Changing this to row and col so we
                                  row_name: eefpst1rc.timepoint_name.name,         # timepoint_name            can use the same names later.
                                  row_unit: eefpst1rc.timepoint_name.unit,         # timepoint_unit
                                  col_id: eefpst1_arm.type1.id,                    # arm_id
                                  col_name: eefpst1_arm.type1.name,                # arm_name
                                  col_description: eefpst1_arm.type1.description,  # arm_description
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
                                row_id: eefpst1rc.timepoint_name.id,     # timepoint_id
                                row_name: eefpst1rc.timepoint_name.name, # timepoint_name
                                row_unit: eefpst1rc.timepoint_name.unit, # timepoint_unit
                                col_id: bac.id,                          # comparison_id
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
                                  row_id: wac.id,                                 # wac_id
                                  col_id: eefpst1_arm.type1.id,                   # arm_id
                                  col_name: eefpst1_arm.type1.name,               # arm_name
                                  col_description: eefpst1_arm.type1.description, # arm_description
                                  measure_id: rssm.measure.id,
                                  measure_name: rssm.measure.name,
                                  rssm_values: wac.comparisons_arms_rssms_values(eefpst1_arm.id, rssm))

                            end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q3-Measure
                          end  # eefps_arm.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_arm|
                        end  # eefps_arms.each do |eefps_arm|  # Arm
                      end  # result_statistic_section.comparisons.each do |wac|

                    when 4  # Net Change - WAC x BAC x q4-Measure.
                      bac_section = result_statistic_section.population.between_arm_comparisons_section
                      wac_section = result_statistic_section.population.within_arm_comparisons_section
                      bac_section.comparisons.each do |bac|
                        wac_section.comparisons.each do |wac|
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
                                row_id: wac.id, # wac_id
                                col_id: bac.id, # bac_id
                                measure_id: rssm.measure.id,
                                measure_name: rssm.measure.name,
                                rssm_values: wac.wacs_bacs_rssms_values(bac.id, rssm))

                          end  # result_statistic_section.result_statistic_sections_measures.each do |rssm|  # q4-Measure
                        end  # wac_section.comparisons.each do |wac|
                      end  # bac_section.comparisons.each do |bac|
                    end  # case result_statistic_section.result_statistic_section_type_id
                  end  # eefpst1r.result_statistic_sections.each do |result_statistic_section|  # Result Statistic Section Quadrant
                end  # eefpst1_outcome.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|  # Population
              end  # eefps_outcome.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1_outcome|  # Outcome.
            end  # eefps_outcomes.each do |eefps_outcome|
          end  # project.extractions.each do |extraction|

          # Start printing rows to the spreadsheet. First the basic headers:
          #['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
          header_row = sheet.add_row sheet_info.header_info

          # Next continue the header row by adding all rssms together.
          sheet_info.rssms.each do |rssm|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row,
                                                            "[Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]")

            # Append to the header if this is new.
            unless found
              title  = ''
              title += "#{ Type1.find(rssm[:outcome_id]).short_name_and_description } - " unless rssm[:outcome_id].blank?
              title += "#{ rssm[:population_name] }"
              title += " - #{ rssm[:result_statistic_section_type_name] }"
              case rssm[:result_statistic_section_type_name]
              when 'Descriptive Statistics'
                title += " - #{ TimepointName.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Type1.find(rssm[:col_id]).pretty_print_export_header }"
              when 'Between Arm Comparisons'
                title += " - #{ TimepointName.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Comparison.find(rssm[:col_id]).pretty_print_export_header }"
              when 'Within Arm Comparisons'
                title += " - #{ Comparison.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Type1.find(rssm[:col_id]).pretty_print_export_header }"
              when 'NET Change'
                title += " - #{ Comparison.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Comparison.find(rssm[:col_id]).pretty_print_export_header }"
              end
              title += " - #{ rssm[:measure_name] }"
#              comment  = '.'
#              comment += "\rDescription: \"#{ qrc[:question_description] }\"" if qrc[:question_description].present?
#              comment += "\rAnswer choices: #{ qrc[:question_row_column_options] }" if qrc[:question_row_column_options].first.present?
              new_cell = header_row.add_cell "#{ title }\r[Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]"
#              sheet.add_comment ref: new_cell, author: 'Export AI', text: comment, visible: false if (qrc[:question_description].present? || qrc[:question_row_column_options].first.present?)
            end  # unless found
          end  # sheet_info.rssms.each do |rssm|

          # Now we add the extraction rows.
          sheet_info.extractions.each do |key, extraction|
            new_row = []
            new_row << extraction[:extraction_info][:extraction_id]
            new_row << extraction[:extraction_info][:username]
            new_row << extraction[:extraction_info][:citation_id]
            new_row << extraction[:extraction_info][:citation_name]
            new_row << extraction[:extraction_info][:refman]
            new_row << extraction[:extraction_info][:pmid]

            # Add question information.
            extraction[:rssms].each do |rssm|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row,
                                                              "[Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]")

              # Something is wrong if it wasn't found.
              unless found
                raise RuntimeError, "Error: Could not find header row: [Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]"
              end

              new_row[column_idx] = rssm[:rssm_values]
            end  # extraction[:questions].each do |q|

            # Done. Let's add the new row.
            sheet.add_row new_row
          end  # sheet_info.extractions.each do |key, extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths 16, 16, 16, 50, 16, 16
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) } - wide") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 3
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
