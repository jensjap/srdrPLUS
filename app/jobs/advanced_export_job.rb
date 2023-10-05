class AdvancedExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  rescue_from(StandardError) do |exception|
    Sentry.capture_exception(exception) if Rails.env.production?
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second).deliver_later
  end

  def perform(*args)
    Axlsx::Package.new do |package|
      @user_email = args.first
      @project =
        Project
        .includes(
          projects_users: { user: :profile, project: :extractions },
          extraction_forms_projects: {
            extraction_forms_projects_sections: [:section, {
              link_to_type1: :section,
              questions: {
                question_rows: {
                  question_row_columns: :question_row_column_fields
                }
              },
              extractions_extraction_forms_projects_sections: {
                extractions_extraction_forms_projects_sections_question_row_column_fields: [
                  :records,
                  {
                    question_row_column_field: {
                      question_row_column: [
                        :question_row_column_type,
                        :question_row_columns_question_row_column_options,
                        {
                          question_row: :question,
                          question_row_columns_question_row_column_options: {
                            followup_field: {
                              extractions_extraction_forms_projects_sections_followup_fields: %i[
                                extractions_extraction_forms_projects_sections_type1
                                extractions_extraction_forms_projects_section
                                records
                              ]
                            }
                          }
                        }
                      ]
                    }
                  }
                ],
                extraction: {
                  citations_project: { citation: :journal },
                  user: :profile,
                  extractions_key_questions_projects_selections: {
                    key_questions_project: :key_question
                  }
                },
                link_to_type1: {
                  extraction: {
                    citations_project: { citation: :journal },
                    user: :profile,
                    extractions_key_questions_projects_selections: {
                      key_questions_project: :key_question
                    }
                  },
                  extractions_extraction_forms_projects_sections_type1s: [
                    :type1,
                    {
                      extractions_extraction_forms_projects_sections_type1_rows:
                      [
                        :population_name,
                        { extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name }
                      ],
                      extractions_extraction_forms_projects_sections_question_row_column_fields: [
                        :records,
                        {
                          question_row_column_field: {
                            question_row_column: [
                              :question_row_column_type,
                              {
                                question_row: :question,
                                question_row_columns_question_row_column_options: {
                                  followup_field: {
                                    extractions_extraction_forms_projects_sections_followup_fields: %i[
                                      extractions_extraction_forms_projects_sections_type1
                                      extractions_extraction_forms_projects_section
                                      records
                                    ]
                                  }
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  ]
                },
                extractions_extraction_forms_projects_sections_type1s: [
                  :type1,
                  {
                    extractions_extraction_forms_projects_sections_type1_rows:
                    [
                      :population_name,
                      {
                        extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name,
                        result_statistic_sections: [
                          :result_statistic_section_type,
                          {
                            result_statistic_sections_measures: [
                              :measure,
                              { tps_arms_rssms: [
                                :extractions_extraction_forms_projects_sections_type1,
                                :records,
                                { timepoint: :timepoint_name }
                              ] }
                            ],
                            comparisons_result_statistic_sections: {
                              comparison: {
                                comparate_groups: {
                                  comparates: :comparable_element
                                }
                              }
                            }
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            }]
          }
        )
        .find(args.second)
      @export_type = args.third
      @package = package
      @package.use_shared_strings = true
      @package.use_autowidth = true
      @highlight = @package.workbook.styles.add_style(
        bg_color: 'C7EECF', fg_color: '09600B', sz: 14,
        font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      )
      @wrap = @package.workbook.styles.add_style(alignment: { wrap_text: true })

      @efp = @project.extraction_forms_projects.first
      efpss = @efp.extraction_forms_projects_sections
      @type1_efpss = efpss.select { |efps| efps.extraction_forms_projects_section_type_id == 1 }
      @linked_type2_efpss = efpss.select do |efps|
        efps.extraction_forms_projects_section_type_id == 2 && efps.link_to_type1.present?
      end
      @unlinked_type2_efpss = efpss.select do |efps|
        efps.extraction_forms_projects_section_type_id == 2 && efps.link_to_type1.blank?
      end
      @outcomes_efps = efpss.find do |efps|
        efps.extraction_forms_projects_section_type_id == 1 && efps.section.name == 'Outcomes'
      end
      @arms_efps = efpss.find do |efps|
        efps.extraction_forms_projects_section_type_id == 1 && efps.section.name == 'Arms'
      end
      @extractions = @project.extractions

      filename = generate_xlsx_and_filename
      raise 'Unable to serialize' unless @package.serialize(filename)
    end
    nil
  end

  def generate_xlsx_and_filename
    # add_project_information_section
    # add_type1_sections
    # add_linked_type2_sections
    # add_unlinked_type2_sections
    add_results
    'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_advanced.xlsx'
  end

  def add_project_information_section
    @package.workbook.add_worksheet(name: 'Project Information') do |sheet|
      sheet.add_row(['Project Information:'], style: [@highlight])
      sheet.add_row(['Name', @project.name])
      sheet.add_row(['Description', @project.description], style: [@wrap])
      sheet.add_row(['Attribution', @project.attribution])
      sheet.add_row(['Methodology Description', @project.methodology_description])
      sheet.add_row(['Prospero', @project.prospero], types: [nil, :string])
      sheet.add_row(['DOI', @project.doi], types: [nil, :string])
      sheet.add_row(['Notes', @project.notes])
      sheet.add_row(['Funding Source', @project.funding_source])
      sheet.add_row(['Project Member List:'], style: [@highlight])
      sheet.add_row(['Username', 'First Name', 'Middle Name', 'Last Name', 'Email', 'Extraction ID'])
      @project.projects_users.each do |projects_user|
        sheet.add_row(
          [
            projects_user.user.profile.username,
            projects_user.user.profile.first_name,
            projects_user.user.profile.middle_name,
            projects_user.user.profile.last_name,
            projects_user.user.email,
            projects_user.project.extractions.select do |extraction|
              extraction.user_id == projects_user.user.id
            end.map(&:id)
          ]
        )
      end
    end
  end

  def add_type1_sections
    @type1_efpss.each do |efps|
      section_name = efps.section.name
      type1s = []
      type1s_lookups = {}
      extractions = []
      extractions_lookups = {}
      units_lookup = {}
      population_names = []
      population_names_lookups = {}
      timepoint_names = []
      timepoint_names_lookups = {}

      eefpss = efps.extractions_extraction_forms_projects_sections
      eefpss.each do |eefps|
        extraction = eefps.extraction
        extractions << extraction unless extractions.include?(extraction)
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          type1 = eefpst1.type1
          type1s << type1 unless type1s.include?(type1)
          type1s_lookups[type1.id] ||= {
            name: type1.name,
            description: type1.description
          }
          units_lookup["#{extraction.id}-#{type1.id}"] = eefpst1.units
          extractions_lookups[extraction.id] ||= { type1s: {}, population_names: {}, timepoint_names: {} }
          extractions_lookups[extraction.id][:type1s][type1.id] = true

          eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
            population_name = eefpst1r.population_name
            population_names << population_name unless population_names.include?(population_name)
            population_names_lookups[population_name.id] ||= {
              name: population_name.name,
              description: population_name.description
            }
            extractions_lookups[extraction.id][:population_names][population_name.id] = true
            eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
              timepoint_name = eefpst1rc.timepoint_name
              timepoint_names << timepoint_name unless timepoint_names.include?(timepoint_name)
              timepoint_names_lookups[timepoint_name.id] ||= {
                name: timepoint_name.name,
                unit: timepoint_name.unit
              }
              extractions_lookups[extraction.id][:timepoint_names][timepoint_name.id] = true
            end
          end
        end
      end
      @package.workbook.add_worksheet(name: section_name) do |sheet|
        headers = default_headers
        type1s.each do |type1|
          header_multiplier = section_name == 'Outcomes' ? 3 : 2
          headers += (["#{efps.section.name} ID: #{type1.id}"] * header_multiplier)
        end
        if section_name == 'Outcomes'
          population_names.each do |population_name|
            headers << "Population ID: #{population_name.id}"
            headers << "Population ID: #{population_name.id}"
          end
          timepoint_names.each do |timepoint_name|
            headers << "Timepoint ID: #{timepoint_name.id}"
            headers << "Timepoint ID: #{timepoint_name.id}"
          end
        end
        sheet.add_row(headers)

        extractions.each do |extraction|
          row = extract_default_row_columns(extraction)
          type1s.each do |type1|
            type_hash = type1s_lookups[type1.id]
            if extractions_lookups.try(:[], extraction.id).try(:[], :type1s).try(:[], type1.id)
              row << type_hash[:name]
              row << type_hash[:description]
              row << units_lookup["#{extraction.id}-#{type1.id}"] if section_name == 'Outcomes'
            else
              row += [nil, nil, nil]
            end
          end
          if section_name == 'Outcomes'
            population_names.each do |population_name|
              if extractions_lookups.try(:[], extraction.id).try(:[], :population_names).try(:[], population_name.id)
                row << population_name.name
                row << population_name.description
              else
                row += [nil, nil]
              end
            end
            timepoint_names.each do |timepoint_name|
              if extractions_lookups.try(:[], extraction.id).try(:[], :timepoint_names).try(:[], timepoint_name.id)
                row << timepoint_name.name
                row << timepoint_name.unit
              else
                row += [nil, nil]
              end
            end
          end
          sheet.add_row(row)
        end
      end
    end
  end

  def add_linked_type2_sections
    @linked_type2_efpss.each do |efps|
      section_name = efps.section.name
      linked_section_name = efps.link_to_type1.try(:section).try(:name)
      extractions = []
      extractions_lookups = {}
      records_lookups = {}

      linked_eefpss = efps.extractions_extraction_forms_projects_sections.map { |eefps| [eefps.link_to_type1, eefps] }
      raise 'must be linked, inconsistent data' if linked_eefpss.any?(&:nil?)

      linked_eefpss.each do |eefps, child_eefps|
        extraction = eefps.extraction
        extractions_lookups[extraction.id] ||= { type1s: [] }
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          type1 = eefpst1.type1
          extractions_lookups[extraction.id][:type1s] << type1
          eefpst1.extractions_extraction_forms_projects_sections_question_row_column_fields.each do |eefpsqrcf|
            qrcf = eefpsqrcf.question_row_column_field
            qrc = qrcf.question_row_column
            qrcqrcos = qrc.question_row_columns_question_row_column_options
            qrct = qrc.question_row_column_type
            qr = qrc.question_row
            q = qr.question
            record = eefpsqrcf.records.first
            name = if QuestionRowColumnType::OPTION_SELECTION_TYPES.include?(qrct.name)
                     begin
                       name = record.name.blank? ? [''] : JSON.parse(record.name)
                       name = [name] unless name.instance_of?(Array)
                       name.select(&:present?).map do |string_id|
                         qrcqrco = qrcqrcos.find(string_id)
                         if qrcqrco.followup_field.nil?
                           qrcqrco.name.to_s
                         else
                           eefpsff =
                             qrcqrco
                             .followup_field
                             &.extractions_extraction_forms_projects_sections_followup_fields
                             &.find do |candidate_eefpsff|
                               candidate_eefpsff.extractions_extraction_forms_projects_sections_type1 == eefpst1 &&
                                 candidate_eefpsff.extractions_extraction_forms_projects_section == child_eefps
                             end
                           "#{qrcqrco.name} [Follow Up: #{eefpsff&.records&.first&.name}]"
                         end
                       end.join("\x0D\x0A")
                     rescue JSON::ParserError, TypeError
                       raise 'record value does not match qrct'
                     end
                   else
                     record.name.to_s
                   end
            records_lookups["#{extraction.id}-#{type1.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrcf.id}"] = name
          end
        end
      end

      eefpss = efps.extractions_extraction_forms_projects_sections
      eefpss.each do |eefps|
        extraction = eefps.extraction
        extractions << extraction unless extractions.include?(extraction)
      end

      questions = efps.questions
      @package.workbook.add_worksheet(name: section_name) do |sheet|
        headers = default_headers
        headers << linked_section_name
        headers << linked_section_name
        questions.each do |q|
          q.question_rows.each do |qr|
            qr.question_row_columns.each do |qrc|
              headers << "[Question ID: #{q.id}][Field ID: #{qr.id}x#{qrc.id}]"
            end
          end
        end
        sheet.add_row(headers)

        extractions.each do |extraction|
          extractions_lookups[extraction.id][:type1s].each do |type1|
            row = extract_default_row_columns(extraction)
            row << type1.name
            row << type1.description
            questions.each do |q|
              q.question_rows.each do |qr|
                qr.question_row_columns.each do |qrc|
                  qrc_records = []
                  qrc.question_row_column_fields.each do |qrcf|
                    record = records_lookups["#{extraction.id}-#{type1.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrcf.id}"]
                    qrc_records << record
                  end
                  row << qrc_records.join("\x0D\x0A")
                end
              end
            end
            sheet.add_row(row)
          end
        end
      end
    end
  end

  def add_unlinked_type2_sections
    @unlinked_type2_efpss.each do |efps|
      section_name = efps.section.name
      extractions = []
      records_lookups = {}

      efps.extractions_extraction_forms_projects_sections.each do |eefps|
        extraction = eefps.extraction
        eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.each do |eefpsqrcf|
          qrcf = eefpsqrcf.question_row_column_field
          qrc = qrcf.question_row_column
          qrcqrcos = qrc.question_row_columns_question_row_column_options
          qrct = qrc.question_row_column_type
          qr = qrc.question_row
          q = qr.question
          record = eefpsqrcf.records.first
          name = if QuestionRowColumnType::OPTION_SELECTION_TYPES.include?(qrct.name)
                   begin
                     name = record.name.blank? ? [''] : JSON.parse(record.name)
                     name = [name] unless name.instance_of?(Array)
                     name.select(&:present?).map do |string_id|
                       qrcqrco = qrcqrcos.find(string_id)
                       if qrcqrco.followup_field.nil?
                         qrcqrco.name.to_s
                       else
                         eefpsff =
                           qrcqrco
                           .followup_field
                           &.extractions_extraction_forms_projects_sections_followup_fields
                           &.find do |candidate_eefpsff|
                             candidate_eefpsff.extractions_extraction_forms_projects_sections_type1.nil? &&
                               candidate_eefpsff.extractions_extraction_forms_projects_section == eefps
                           end
                         "#{qrcqrco.name} [Follow Up: #{eefpsff&.records&.first&.name}]"
                       end
                     end.join("\x0D\x0A")
                   rescue JSON::ParserError, TypeError
                     raise 'record value does not match qrct'
                   end
                 else
                   record.name.to_s
                 end
          records_lookups["#{extraction.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrcf.id}"] = name
        end
      end

      eefpss = efps.extractions_extraction_forms_projects_sections
      eefpss.each do |eefps|
        extraction = eefps.extraction
        extractions << extraction unless extractions.include?(extraction)
      end

      questions = efps.questions
      @package.workbook.add_worksheet(name: section_name) do |sheet|
        headers = default_headers
        questions.each do |q|
          q.question_rows.each do |qr|
            qr.question_row_columns.each do |qrc|
              headers << "[Question ID: #{q.id}][Field ID: #{qr.id}x#{qrc.id}]"
            end
          end
        end
        sheet.add_row(headers)

        extractions.each do |extraction|
          row = extract_default_row_columns(extraction)
          questions.each do |q|
            q.question_rows.each do |qr|
              qr.question_row_columns.each do |qrc|
                qrc_records = []
                qrc.question_row_column_fields.each do |qrcf|
                  record = records_lookups["#{extraction.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrcf.id}"]
                  qrc_records << record
                end
                row << qrc_records.join("\x0D\x0A")
              end
            end
          end
          sheet.add_row(row)
        end
      end
    end
  end

  # TODO: 1
  # measures are not unique in the db.
  # need to deduplicate the table and update its children
  def add_results
    q11_measures = []
    q12_measures = []
    q21_measures = []
    q22_measures = []
    q3_measures = []
    q4_measures = []
    arms_lookups = {}
    max_no_of_arms = 0
    records_lookups = {}

    extractions_lookups = {}
    @arms_efps.extractions_extraction_forms_projects_sections.each do |eefps|
      extraction = eefps.extraction
      extractions_lookups[extraction.id] ||= {
        outcomes: {},
        arms: {}
      }
      eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
        extractions_lookups[extraction.id][:arms][eefpst1.type1.id] = eefpst1
        arms_lookups[extraction.id] ||= []
        arms_lookups[extraction.id] << eefpst1.type1 unless arms_lookups[extraction.id].include?(eefpst1.type1)
      end
    end
    @outcomes_efps.extractions_extraction_forms_projects_sections.each do |eefps|
      extraction = eefps.extraction
      extractions_lookups[extraction.id] ||= {
        outcomes: {},
        arms: {}
      }
      eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
        extractions_lookups[extraction.id][:outcomes][eefpst1.type1.id] ||= {
          record: eefpst1,
          populations: {}
        }
        eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
          extractions_lookups[extraction.id][:outcomes][eefpst1.type1.id][:populations][eefpst1r.population_name.id] ||= {
            record: eefpst1r,
            timepoints: {}
          }
          eefpst1r.result_statistic_sections.each do |rss|
            next if rss.result_statistic_section_type_id > 4

            rss.result_statistic_sections_measures.each do |rssm|
              case rss.result_statistic_section_type_id
              when 1
                if eefpst1.type1_type_id == 1
                  # See TODO 1
                  q11_measures << rssm.measure unless q11_measures.any? { |measure| measure.name == rssm.measure.name }
                elsif eefpst1.type1_type_id == 2
                  # See TODO 1
                  q12_measures << rssm.measure unless q12_measures.any? { |measure| measure.name == rssm.measure.name }
                end
              when 2
                if eefpst1.type1_type_id == 1
                  # See TODO 1
                  q21_measures << rssm.measure unless q21_measures.any? { |measure| measure.name == rssm.measure.name }
                elsif eefpst1.type1_type_id == 2
                  # See TODO 1
                  q22_measures << rssm.measure unless q22_measures.any? { |measure| measure.name == rssm.measure.name }
                end
              when 3
                # See TODO 1
                q3_measures << rssm.measure unless q3_measures.any? { |measure| measure.name == rssm.measure.name }
              when 4
                # See TODO 1
                q4_measures << rssm.measure unless q4_measures.any? { |measure| measure.name == rssm.measure.name }
              end
              # "#{extraction.id}-#{eefpst1.type1.id}-#{type1.id}-#{rssm.measure.name}"
              rssm.tps_arms_rssms.each do |tps_arms_rssm|
                # TODO: 2 cleanup any tps_arms_rssm that are linked to non-existing eefpst1rc
                next if tps_arms_rssm.timepoint.nil?

                record = tps_arms_rssm.records.first
                # See TODO 1
                records_lookups["#{extraction.id}-#{eefpst1.type1.id}-#{eefpst1r.population_name.id}-#{tps_arms_rssm.timepoint.timepoint_name.id}-#{tps_arms_rssm.extractions_extraction_forms_projects_sections_type1.type1_id}-#{rssm.measure.name}"] =
                  record.name
              end
              # rssm.tps_comparisons_rssms.each do |tps_comparisons_rssm|
              # end
              # rssm.comparisons_arms_rssms.each do |comparisons_arms_rssm|
              # end
              # rssm.wacs_bacs_rssms.each do |wacs_bacs_rssm|
              # end
            end

            rss.comparisons_result_statistic_sections.each do |comparisons_result_statistic_section|
              comparisons_result_statistic_section.comparison.comparate_groups.each do |comparate_group|
                comparate_group.comparates.each do |comparate|
                  comparate.comparable_element
                end
              end
            end
          end
          eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
            extractions_lookups[extraction.id][:outcomes][eefpst1.type1.id][:populations][eefpst1r.population_name.id][:timepoints][eefpst1rc.timepoint_name.id] ||= {
              record: eefpst1rc
            }
          end
        end
      end
    end
    max_no_of_arms = arms_lookups.values.max_by(&:length)&.length || 0
    @package.workbook.add_worksheet(name: 'Continuous - Desc. Statistics') do |sheet|
      headers = default_headers
      headers += %w[Outcome Description Type Population Description Digest Timepoint Unit]
      max_no_of_arms.times do |max_no_of_arms_index|
        headers += ["Arm Name #{max_no_of_arms_index + 1}", "Arm Description #{max_no_of_arms_index + 1}"]
        q11_measures.each do |measure|
          headers << measure.name
        end
      end
      sheet.add_row(headers)

      @outcomes_efps.extractions_extraction_forms_projects_sections.each do |eefps|
        extraction = eefps.extraction
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          next if eefpst1.type1_type_id != 2

          eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
            eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
              row = extract_default_row_columns(extraction)
              row += [
                eefpst1.type1.name,
                eefpst1.type1.description,
                print_type1_type(eefpst1.type1_type_id),
                eefpst1r.population_name.name,
                eefpst1r.population_name.description,
                'Digest',
                eefpst1rc.timepoint_name.name,
                eefpst1rc.timepoint_name.unit
              ]
              arms_lookups[extraction.id].each do |type1|
                row += [type1.name, type1.description]
                q12_measures.each do |measure|
                  # See TODO 1
                  record_name = records_lookups["#{extraction.id}-#{eefpst1.type1.id}-#{eefpst1r.population_name.id}-#{eefpst1rc.timepoint_name.id}-#{type1.id}-#{measure.name}"]
                  row << record_name
                end
              end
              sheet.add_row(row)
            end
          end
        end
      end
      sheet.column_widths(*([12] * sheet.rows.first.cells.length))
    end
  end

  private

  def default_headers
    ['Extraction ID', 'Consolidated', 'Username', 'Citation ID', 'Citation Name', 'RefMan',
     'other_reference', 'PMID', 'Authors', 'Publication Date', 'Key Questions']
  end

  def extract_default_row_columns(extraction)
    [
      extraction.id,
      extraction.consolidated,
      extraction.user.profile.username,
      extraction.citations_project.citation.id,
      extraction.citations_project.citation.name,
      extraction.citations_project.citation.refman,
      extraction.citations_project.citation.other,
      extraction.citations_project.citation.pmid,
      extraction.citations_project.citation.authors,
      extraction.citations_project.citation.year,
      extraction.extractions_key_questions_projects_selections.map do |ekqps|
        ekqps.key_questions_project.key_question.name
      end.join("\x0D\x0A")
    ]
  end

  def print_type1_type(type1_type_id)
    case type1_type_id
    when 1
      'Categorical'
    when 2
      'Continuous'
    end
  end
end
