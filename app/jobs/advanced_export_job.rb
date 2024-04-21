class AdvancedExportJob < ApplicationJob
  require 'axlsx'
  queue_as :default

  WORKSHEET_NAME_FORBIDDEN_CHARS = '[]*/\?:'.chars.freeze
  COLORS = %w[FFBABA FFF3BA C5B7F1 B3F6B3].freeze
  RESERVED_WORKSHEET_NAMES = [
    'Project Information',
    'Continuous - Desc. Statistics',
    'Categorical - Desc. Statistics',
    'Continuous - BAC Comparisons',
    'Categorical - BAC Comparisons',
    'WAC Comparisons',
    'NET Differences'
  ].freeze

  rescue_from(StandardError) do |exception|
    Sentry.capture_exception(exception) if Rails.env.production?
    debugger if Rails.env.development?
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
                  question_row_columns: %i[question_row_column_fields question_row_column_type
                                           question_row_columns_question_row_column_options]
                }
              },
              extractions_extraction_forms_projects_sections: {
                extractions_extraction_forms_projects_sections_question_row_column_fields: [
                  :records,
                  {
                    extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options: :question_row_columns_question_row_column_option,
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
                          extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options: :question_row_columns_question_row_column_option,
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
                              :measure, {
                                tps_arms_rssms: [
                                  :records,
                                  :extractions_extraction_forms_projects_sections_type1,
                                  { timepoint: :timepoint_name }
                                ],
                                tps_comparisons_rssms: [
                                  :records,
                                  {
                                    timepoint: :timepoint_name,
                                    comparison: {
                                      comparate_groups: {
                                        comparates: {
                                          comparable_element: {
                                            comparable: :type1
                                          }
                                        }
                                      }
                                    }
                                  }
                                ],
                                comparisons_arms_rssms: [
                                  :records,
                                  :extractions_extraction_forms_projects_sections_type1,
                                  {
                                    comparison: {
                                      comparate_groups: {
                                        comparates: {
                                          comparable_element: {
                                            comparable: :timepoint_name
                                          }
                                        }
                                      }
                                    }
                                  }
                                ],
                                wacs_bacs_rssms: [
                                  :records,
                                  {
                                    wac: {
                                      comparate_groups: {
                                        comparates: {
                                          comparable_element: {
                                            comparable: :timepoint_name
                                          }
                                        }
                                      }
                                    },
                                    bac: {
                                      comparate_groups: {
                                        comparates: {
                                          comparable_element: {
                                            comparable: :type1
                                          }
                                        }
                                      }
                                    }
                                  }
                                ]
                              }
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
      @package = package
      @package.use_shared_strings = true
      @package.use_autowidth = true
      @highlight = @package.workbook.styles.add_style(
        bg_color: 'C7EECF', fg_color: '09600B', sz: 14,
        font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      )
      @wrap = @package.workbook.styles.add_style(alignment: { wrap_text: true })
      @styles = COLORS.map { |color| @package.workbook.styles.add_style(bg_color: color) }

      @efp = @project.extraction_forms_projects.first
      efpss = @efp.extraction_forms_projects_sections
      @type1_efpss = efpss.select { |efps| efps.extraction_forms_projects_section_type_id == 1 }
      @linked_type2_efpss = efpss.select do |efps|
        efps.extraction_forms_projects_section_type_id == 2 && efps.link_to_type1.present? && efps.extraction_forms_projects_section_option.by_type1
      end
      @unlinked_type2_efpss = efpss.select do |efps|
        (efps.extraction_forms_projects_section_type_id == 2 && efps.link_to_type1.blank?) ||
        (efps.extraction_forms_projects_section_type_id == 2 && efps.link_to_type1.present? && !efps.extraction_forms_projects_section_option.by_type1)
      end
      @outcomes_efps = efpss.find do |efps|
        efps.extraction_forms_projects_section_type_id == 1 && efps.section.name == 'Outcomes'
      end
      @arms_efps = efpss.find do |efps|
        efps.extraction_forms_projects_section_type_id == 1 && efps.section.name == 'Arms'
      end

      @project.extractions&.each(&:ensure_extraction_form_structure)
      @extractions = @project.extractions

      filename = generate_xlsx_and_filename
      raise 'Unable to serialize' unless @package.serialize(filename)

      exported_item = create_email_export(filename)
      ExportMailer.notify_simple_export_completion(exported_item.id).deliver_later
    end
    nil
  end

  def generate_xlsx_and_filename
    add_project_information_section
    add_type1_sections
    add_linked_type2_sections
    add_unlinked_type2_sections
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

      sheet.column_widths(*([12] * 6))
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
      @package.workbook.add_worksheet(name: ensure_unique_sheet_name(section_name)) do |sheet|
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

        sheet.column_widths(*([12] * sheet.rows.first.cells.length))
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

      linked_eefpss = efps.extractions_extraction_forms_projects_sections.map do |eefps|
        eefps.reload
        [eefps.link_to_type1, eefps]
      end
      raise 'must be linked, inconsistent data' if linked_eefpss.any? do |link_to_type1, eefps|
                                                     link_to_type1.nil? || eefps.nil?
                                                   end

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
            next if record.nil?

            name = if qrct.name == QuestionRowColumnType::SELECT2_MULTI
                     eefpsqrcf.extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options.map do |eefpsqrcfqrcqrco|
                       eefpsqrcfqrcqrco.question_row_columns_question_row_column_option.name
                     end.join("\x0D\x0A")
                   elsif QuestionRowColumnType::OPTION_SELECTION_TYPES.include?(qrct.name)
                     begin
                       name = record.name.blank? ? [''] : JSON.parse(record.name)
                       name = [name] unless name.instance_of?(Array)
                       name.select(&:present?).map do |string_id|
                         qrcqrco = qrcqrcos.find { |qrc_qrco| qrc_qrco.id.to_s == string_id.to_s }
                         if qrcqrco.nil?
                           ''
                         elsif qrcqrco.followup_field.nil?
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
                           "#{qrcqrco.name}[Follow-up: #{eefpsff&.records&.first&.name}]"
                         end
                       end.join("\x0D\x0A")
                     rescue JSON::ParserError, TypeError => e
                       Sentry.capture_exception(e) if Rails.env.production?
                       ''
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
      @package.workbook.add_worksheet(name: ensure_unique_sheet_name(section_name)) do |sheet|
        headers = default_headers
        headers << "#{linked_section_name} Name"
        headers << "#{linked_section_name} #{linked_section_name == 'Outcomes' ? 'Unit' : 'Description'}"
        row = sheet.add_row(headers)
        questions.each do |q|
          q.question_rows.each do |qr|
            qr.question_row_columns.each do |qrc|
              title  = ''
              title += q.name
              title += " - #{qr.name}" if qr.name.present?
              title += " - #{qrc.name}" if qrc.name.present?
              qrcoqrcos = qrc.question_row_columns_question_row_column_options.select do |qrcqrco|
                qrcqrco.question_row_column_option_id == 1
              end
              comment  = '.'
              comment += "\rDescription: \"#{q.description}\"" if q.description.present?
              if QuestionRowColumnType::OPTION_SELECTION_TYPES.include?(qrc.question_row_column_type.name)
                comment += "\rAnswer choices:"
                qrcoqrcos.each do |qrcoqrco|
                  comment += "\r    [Option ID: #{qrcoqrco.id}] #{qrcoqrco.name}"
                end
              end

              cell = row.add_cell("#{title}\r[Question ID: #{q.id}][Field ID: #{qr.id}x#{qrc.id}]")
              if q.description.present? || qrcoqrcos.present?
                sheet.add_comment(ref: cell, author: 'Export AI', text: comment, visible: false)
              end
            end
          end
        end

        extractions.each do |extraction|
          extractions_lookups[extraction.id][:type1s].each do |type1|
            row = extract_default_row_columns(extraction)
            row << type1.name
            row << type1.description
            questions.each do |q|
              q.question_rows.each do |qr|
                qr.question_row_columns.each do |qrc|
                  qrct = qrc.question_row_column_type
                  if qrct.name == QuestionRowColumnType::NUMERIC
                    qrc_records = []
                    qrc.question_row_column_fields[0..1].each do |qrcf|
                      qrc_records << records_lookups["#{extraction.id}-#{type1.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrcf.id}"]
                    end
                    row << qrc_records.join(' ')
                  else
                    row << records_lookups["#{extraction.id}-#{type1.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrc.question_row_column_fields.first.id}"]
                  end
                end
              end
            end
            sheet.add_row(row)
          end
        end

        sheet.column_widths(*([12] * sheet.rows.first.cells.length))
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
          next if record.nil?

          name = if qrct.name == QuestionRowColumnType::SELECT2_MULTI
                   eefpsqrcf.extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options.map do |eefpsqrcfqrcqrco|
                     eefpsqrcfqrcqrco.question_row_columns_question_row_column_option.name
                   end.join("\x0D\x0A")
                 elsif QuestionRowColumnType::OPTION_SELECTION_TYPES.include?(qrct.name)
                   begin
                     name = record.name.blank? ? [''] : JSON.parse(record.name)
                     name = [name] unless name.instance_of?(Array)
                     name.select(&:present?).map do |string_id|
                       qrcqrco = qrcqrcos.find { |qrc_qrco| qrc_qrco.id.to_s == string_id.to_s }
                       if qrcqrco.nil?
                         ''
                       elsif qrcqrco.followup_field.nil?
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
                         "#{qrcqrco.name}[Follow-up: #{eefpsff&.records&.first&.name}]"
                       end
                     end.join("\x0D\x0A")
                   rescue JSON::ParserError, TypeError => e
                     Sentry.capture_exception(e) if Rails.env.production?
                     ''
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
        raise 'inconsistent data' if extraction.nil?

        extractions << extraction unless extractions.include?(extraction)
      end

      questions = efps.questions
      @package.workbook.add_worksheet(name: ensure_unique_sheet_name(section_name)) do |sheet|
        headers = default_headers
        row = sheet.add_row(headers)
        questions.each do |q|
          q.question_rows.each do |qr|
            qr.question_row_columns.each do |qrc|
              title  = ''
              title += q.name
              title += " - #{qr.name}" if qr.name.present?
              title += " - #{qrc.name}" if qrc.name.present?
              qrcoqrcos = qrc.question_row_columns_question_row_column_options.select do |qrcqrco|
                qrcqrco.question_row_column_option_id == 1
              end
              comment  = '.'
              comment += "\rDescription: \"#{q.description}\"" if q.description.present?
              if QuestionRowColumnType::OPTION_SELECTION_TYPES.include?(qrc.question_row_column_type.name)
                comment += "\rAnswer choices:"
                qrcoqrcos.each do |qrcoqrco|
                  comment += "\r    [Option ID: #{qrcoqrco.id}] #{qrcoqrco.name}"
                end
              end

              cell = row.add_cell("#{title}\r[Question ID: #{q.id}][Field ID: #{qr.id}x#{qrc.id}]")
              if q.description.present? || qrcoqrcos.present?
                sheet.add_comment(ref: cell, author: 'Export AI', text: comment, visible: false)
              end
            end
          end
        end

        extractions.each do |extraction|
          row = extract_default_row_columns(extraction)
          questions.each do |q|
            q.question_rows.each do |qr|
              qr.question_row_columns.each do |qrc|
                qrct = qrc.question_row_column_type
                if qrct.name == QuestionRowColumnType::NUMERIC
                  qrc_records = []
                  qrc.question_row_column_fields[0..1].each do |qrcf|
                    qrc_records << records_lookups["#{extraction.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrcf.id}"]
                  end
                  row << qrc_records.join(' ')
                else
                  row << records_lookups["#{extraction.id}-#{q.id}-#{qr.id}-#{qrc.id}-#{qrc.question_row_column_fields.first.id}"]
                end
              end
            end
          end
          sheet.add_row(row)
        end

        sheet.column_widths(*([12] * sheet.rows.first.cells.length))
      end
    end
  end

  # NOTE: 1
  # a qrc should have at most 2 qrcfs (in the case of numeric fields to allow for equality) but many qrc have more
  # eefpsqrcf are directly linked to eefps without any intermediary qrc

  # NOTE: 2
  # some section names attempt to inject javascript and contain characters incompatible with excel sheet names

  # TODO: 1
  # measures are not unique in the db.
  # need to deduplicate the table and update its children
  # remove .any? { |measure| measure.name == rssm.measure.name }

  # TODO: 2
  # cleanup any tps_arms_rssm that are linked to non-existing eefpst1rc
  # TpsArmsRssm.left_joins(:timepoint).where(extractions_extraction_forms_projects_sections_type1_row_columns: { id: nil }).count
  # remove next if (timepoint = tps_comparisons_rssm.timepoint).nil?

  # TODO: 3
  # some outcomes are missing type1_type_id eefpst1.type1_type_id

  # TODO: 4
  # remove unknown type1_type_id

  # TODO: 5
  # a significant number of users lack profiles

  # TODO: 5
  # many corrupted record json that do not match the qrctype

  # TODO: 6
  # some eefps do not have an extraction

  def add_results
    return unless @arms_efps.present? && @outcomes_efps.present?

    measures_lookups = {
      1 => { 1 => [], 2 => [] },
      2 => { 1 => [], 2 => [] },
      3 => [],
      4 => []
    }
    arms_lookups = {}
    comparisons_lookups = {
      1 => { 1 => {}, 2 => {} },
      2 => { 1 => {}, 2 => {} },
      3 => { 1 => {}, 2 => {} },
      4 => { 1 => {}, 2 => {} }
    }
    q4_comparisons_no_lookups = {}
    records_lookups = Hash.new([false, ''])

    @arms_efps.extractions_extraction_forms_projects_sections.each do |eefps|
      extraction = eefps.extraction
      eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
        arms_lookups[extraction.id] ||= []
        arms_lookups[extraction.id] << eefpst1.type1 unless arms_lookups[extraction.id].include?(eefpst1.type1)
      end
    end
    @outcomes_efps.extractions_extraction_forms_projects_sections.each do |eefps|
      extraction = eefps.extraction
      eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
        type1_type_id = eefpst1.type1_type_id || 1
        begin
          raise 'inconsistent data' if type1_type_id > 2
        rescue JSON::ParserError, TypeError => e
          Sentry.capture_exception(e) if Rails.env.production?
          next
        end

        eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
          eefpst1r.result_statistic_sections.each do |rss|
            next if (rsst_id = rss.result_statistic_section_type_id) > 4

            q4_comparisons_no_lookups[eefpst1.id] ||= {
              no_of_bacs: 0,
              no_of_wacs: 0
            }
            if rss.result_statistic_section_type_id == 2
              q4_comparisons_no_lookups[eefpst1.id][:no_of_bacs] =
                rss.comparisons_result_statistic_sections.length
            end
            if rss.result_statistic_section_type_id == 3
              q4_comparisons_no_lookups[eefpst1.id][:no_of_wacs] =
                rss.comparisons_result_statistic_sections.length
            end

            rss.result_statistic_sections_measures.each do |rssm|
              case rsst_id
              when 1, 2
                measures_lookups[rsst_id][type1_type_id] << rssm.measure unless measures_lookups[rsst_id][type1_type_id].any? do |measure|
                                                                                  measure.name == rssm.measure.name
                                                                                end
              when 3, 4
                measures_lookups[rsst_id] << rssm.measure unless measures_lookups[rsst_id].any? do |measure|
                                                                   measure.name == rssm.measure.name
                                                                 end
              end
              rssm.tps_arms_rssms.each do |tps_arms_rssm|
                next if (timepoint = tps_arms_rssm.timepoint).nil?
                next if (arm_eefpst1 = tps_arms_rssm.extractions_extraction_forms_projects_sections_type1).nil?

                records_lookups["tps_arms_rssms-#{extraction.id}-#{eefpst1.type1_id}-#{eefpst1r.population_name.id}-#{timepoint.timepoint_name.id}-#{arm_eefpst1.type1_id}-#{rssm.measure.name}"] =
                  [true, tps_arms_rssm.records.first&.name.to_s]
              end
              rssm.tps_comparisons_rssms.each do |tps_comparisons_rssm|
                next if (timepoint = tps_comparisons_rssm.timepoint).nil?
                next if (comparison = tps_comparisons_rssm.comparison).nil?

                records_lookups["tps_comparisons_rssms-#{extraction.id}-#{eefpst1.type1_id}-#{eefpst1r.population_name.id}-#{timepoint.timepoint_name.id}-#{comparison.id}-#{rssm.measure.name}"] =
                  [true, tps_comparisons_rssm.records.first&.name.to_s]
              end
              rssm.comparisons_arms_rssms.each do |comparisons_arms_rssm|
                next if (comparison = comparisons_arms_rssm.comparison).nil?
                next if (arm_eefpst1 = comparisons_arms_rssm.extractions_extraction_forms_projects_sections_type1).nil?

                records_lookups["comparisons_arms_rssms-#{extraction.id}-#{eefpst1.type1_id}-#{eefpst1r.population_name.id}-#{comparison.id}-#{arm_eefpst1.type1_id}-#{rssm.measure.name}"] =
                  [true, comparisons_arms_rssm.records.first&.name.to_s]
              end
              rssm.wacs_bacs_rssms.each do |wacs_bacs_rssm|
                next if (wac = wacs_bacs_rssm.wac).nil?
                next if (bac = wacs_bacs_rssm.bac).nil?

                records_lookups["wacs_bacs_rssms-#{extraction.id}-#{eefpst1.type1_id}-#{eefpst1r.population_name.id}-#{wac.id}-#{bac.id}-#{rssm.measure.name}"] =
                  [true, wacs_bacs_rssm.records.first&.name.to_s]
              end
            end

            comparisons_lookups[rsst_id][type1_type_id][rss.id] ||= []
            rss.comparisons_result_statistic_sections.each do |crss|
              unless comparisons_lookups[rsst_id][type1_type_id][rss.id].include?(crss.comparison)
                comparisons_lookups[rsst_id][type1_type_id][rss.id] << crss.comparison
              end
            end
          end
        end
      end
    end

    # Quadrant 1
    [['Categorical - Desc. Statistics', 1], ['Continuous - Desc. Statistics', 2]].each do |sheet_name, type1_type_id|
      max_no_of_arms = arms_lookups.values.max_by(&:length)&.length || 0
      all_measures = measures_lookups[1][type1_type_id]
      @package.workbook.add_worksheet(name: sheet_name) do |sheet|
        headers = default_headers
        headers += %w[Outcome Description Type Population Description Digest Timepoint Unit]
        styles = [nil] * headers.length
        max_no_of_arms.times do |max_no_of_arms_index|
          headers += ["Arm Name #{max_no_of_arms_index + 1}", "Arm Description #{max_no_of_arms_index + 1}"]
          all_measures.each do |measure|
            headers << measure.name
          end
        end
        max_no_of_arms.times { |header_index| styles += ([@styles[header_index % 4]] * (all_measures.length + 2)) }
        sheet.add_row(headers, style: styles)

        @outcomes_efps.extractions_extraction_forms_projects_sections.each do |eefps|
          extraction = eefps.extraction
          eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
            next if eefpst1.type1_type_id != type1_type_id || arms_lookups[extraction.id].blank?

            eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
              eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
                row = extract_default_row_columns(extraction)
                row += [
                  eefpst1.type1.name,
                  eefpst1.type1.description,
                  print_type1_type(type1_type_id),
                  eefpst1r.population_name.name,
                  eefpst1r.population_name.description,
                  '#',
                  eefpst1rc.timepoint_name.name,
                  eefpst1rc.timepoint_name.unit
                ]
                row_style = [nil] * row.length
                arms_lookups[extraction.id].each_with_index do |type1, type1_index|
                  row += [type1.name, type1.description]
                  row_style += [@styles[type1_index % 4]] * 2
                  all_measures.each do |measure|
                    exists, record_name = records_lookups["tps_arms_rssms-#{extraction.id}-#{eefpst1.type1.id}-#{eefpst1r.population_name.id}-#{eefpst1rc.timepoint_name.id}-#{type1.id}-#{measure.name}"]
                    row << record_name
                    row_style << (exists ? @styles[type1_index % 4] : nil)
                  end
                end
                sheet.add_row(row, style: row_style)
              end
            end
          end
        end
        sheet.column_widths(*([12] * sheet.rows.first.cells.length))
      end
    end

    # Quadrant 2
    [['Categorical - BAC Comparisons', 1], ['Continuous - BAC Comparisons', 2]].each do |sheet_name, type1_type_id|
      bac_comparisons = comparisons_lookups[2][type1_type_id]
      max_no_of_comparisons = bac_comparisons&.values&.max_by(&:length)&.length || 0
      all_measures = measures_lookups[2][type1_type_id]
      @package.workbook.add_worksheet(name: sheet_name) do |sheet|
        headers = default_headers
        headers += %w[Outcome Description Type Population Description Digest Timepoint Unit]
        styles = [nil] * headers.length
        max_no_of_comparisons.times do |max_no_of_comparisons_index|
          headers << "Comparison Name #{max_no_of_comparisons_index + 1}"
          all_measures.each do |measure|
            headers << measure.name
          end
        end
        max_no_of_comparisons.times do |header_index|
          styles += ([@styles[header_index % 4]] * (all_measures.length + 1))
        end
        sheet.add_row(headers, style: styles)

        @outcomes_efps.extractions_extraction_forms_projects_sections.each do |eefps|
          extraction = eefps.extraction
          eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
            next if eefpst1.type1_type_id != type1_type_id

            eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
              eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
                rss = eefpst1r.result_statistic_sections.find do |result_statistic_section|
                  result_statistic_section.result_statistic_section_type_id == 2
                end
                next if rss.nil? || bac_comparisons[rss.id].blank?

                row = extract_default_row_columns(extraction)
                row += [
                  eefpst1.type1.name,
                  eefpst1.type1.description,
                  print_type1_type(type1_type_id),
                  eefpst1r.population_name.name,
                  eefpst1r.population_name.description,
                  '#',
                  eefpst1rc.timepoint_name.name,
                  eefpst1rc.timepoint_name.unit
                ]
                row_style = [nil] * row.length

                bac_comparisons[rss.id].each_with_index do |comparison, comparison_index|
                  g1, g2 = comparison.comparate_groups.map do |comparate_group|
                    comparate_group.comparates.map do |comparate|
                      comparate.comparable_element.comparable.type1.name
                    end.join(', ')
                  end
                  row << if comparison.is_anova
                           "[ID: #{comparison.id}] ANOVA Comparison"
                         else
                           "[ID: #{comparison.id}] [#{g1}] vs. [#{g2}]"
                         end
                  row_style << @styles[comparison_index % 4]
                  all_measures.each do |measure|
                    exists, record_name = records_lookups["tps_comparisons_rssms-#{extraction.id}-#{eefpst1.type1_id}-#{eefpst1r.population_name.id}-#{eefpst1rc.timepoint_name.id}-#{comparison.id}-#{measure.name}"]
                    row << record_name
                    row_style << (exists ? @styles[comparison_index % 4] : nil)
                  end
                end

                sheet.add_row(row, style: row_style)
              end
            end
          end
        end
        sheet.column_widths(*([12] * sheet.rows.first.cells.length))
      end
    end

    # Quadrant 3
    wac_comparisons = comparisons_lookups[3][1].merge(comparisons_lookups[3][2])
    max_no_of_arms = arms_lookups.values.max_by(&:length)&.length || 0
    all_measures = measures_lookups[3]
    @package.workbook.add_worksheet(name: 'WAC Comparisons') do |sheet|
      headers = default_headers
      headers += ['Outcome', 'Description', 'Type', 'Population', 'Description', 'Digest', 'WAC Comparator']
      styles = [nil] * headers.length
      max_no_of_arms.times do |max_no_of_arms_index|
        headers += ["Arm Name #{max_no_of_arms_index + 1}", "Arm Description #{max_no_of_arms_index + 1}"]
        all_measures.each do |measure|
          headers << measure.name
        end
      end
      max_no_of_arms.times { |header_index| styles += ([@styles[header_index % 4]] * (all_measures.length + 2)) }
      sheet.add_row(headers, style: styles)

      @outcomes_efps.extractions_extraction_forms_projects_sections.each do |eefps|
        extraction = eefps.extraction
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
            rss = eefpst1r.result_statistic_sections.find do |result_statistic_section|
              result_statistic_section.result_statistic_section_type_id == 3
            end
            next if rss.nil? || wac_comparisons[rss.id].blank? || arms_lookups[extraction.id].blank?

            wac_comparisons[rss.id].each do |comparison|
              row = extract_default_row_columns(extraction)
              row += [
                eefpst1.type1.name,
                eefpst1.type1.description,
                print_type1_type(eefpst1.type1_type_id),
                eefpst1r.population_name.name,
                eefpst1r.population_name.description,
                '#'
              ]
              row_style = [nil] * (row.length + 1)

              g1, g2 = comparison.comparate_groups.map do |comparate_group|
                comparate_group.comparates.map do |comparate|
                  raise 'inconsistent data' if comparate.comparable_element.comparable.nil?

                  comparate.comparable_element.comparable.timepoint_name.name
                end.join(', ')
              end
              row << "[ID: #{comparison.id}] [#{g1}] vs. [#{g2}]"
              arms_lookups[extraction.id].each_with_index do |type1, type1_index|
                row += [type1.name, type1.description]
                row_style += [@styles[type1_index % 4]] * 2
                all_measures.each do |measure|
                  exists, record_name = records_lookups["comparisons_arms_rssms-#{extraction.id}-#{eefpst1.type1_id}-#{eefpst1r.population_name.id}-#{comparison.id}-#{type1.id}-#{measure.name}"]
                  row << record_name
                  row_style << (exists ? @styles[type1_index % 4] : nil)
                end
              end

              sheet.add_row(row, style: row_style)
            end
          end
        end
      end
      sheet.column_widths(*([12] * sheet.rows.first.cells.length))
    end

    # Quadrant 4
    bac_comparisons = comparisons_lookups[2][1].merge(comparisons_lookups[2][2])
    wac_comparisons = comparisons_lookups[3][1].merge(comparisons_lookups[3][2])
    max_no_of_comparisons = q4_comparisons_no_lookups.keys.map do |key|
      no_of_bacs = q4_comparisons_no_lookups[key][:no_of_bacs]
      no_of_wacs = q4_comparisons_no_lookups[key][:no_of_wacs]
      no_of_wacs.zero? ? 0 : no_of_bacs
    end.max || 0
    all_measures = measures_lookups[4]
    @package.workbook.add_worksheet(name: 'NET Differences') do |sheet|
      headers = default_headers
      headers += ['Outcome', 'Description', 'Type', 'Population', 'Description', 'Digest', 'WAC Comparator']
      styles = [nil] * headers.length
      max_no_of_comparisons.times do |max_no_of_comparisons_index|
        headers << "Comparison Name #{max_no_of_comparisons_index + 1}"
        all_measures.each do |measure|
          headers << measure.name
        end
      end
      max_no_of_comparisons.times { |header_index| styles += ([@styles[header_index % 4]] * (all_measures.length + 1)) }
      sheet.add_row(headers, style: styles)

      @outcomes_efps.extractions_extraction_forms_projects_sections.each do |eefps|
        extraction = eefps.extraction
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
            rss2 = eefpst1r.result_statistic_sections.find do |result_statistic_section|
              result_statistic_section.result_statistic_section_type_id == 2
            end
            rss3 = eefpst1r.result_statistic_sections.find do |result_statistic_section|
              result_statistic_section.result_statistic_section_type_id == 3
            end
            next if rss2.nil? || rss3.nil? || bac_comparisons[rss2.id].blank? || wac_comparisons[rss3.id].blank?

            wac_comparisons[rss3.id].each do |wac_comparison|
              row = extract_default_row_columns(extraction)
              row += [
                eefpst1.type1.name,
                eefpst1.type1.description,
                print_type1_type(eefpst1.type1_type_id),
                eefpst1r.population_name.name,
                eefpst1r.population_name.description,
                '#'
              ]
              row_style = [nil] * (row.length + 1)

              g1, g2 = wac_comparison.comparate_groups.map do |comparate_group|
                comparate_group.comparates.map do |comparate|
                  comparate.comparable_element.comparable.timepoint_name.name
                end.join(', ')
              end
              row << "[ID: #{wac_comparison.id}] [#{g1}] vs. [#{g2}]"
              bac_comparisons[rss2.id].each_with_index do |bac_comparison, bac_comparison_index|
                g1, g2 = bac_comparison.comparate_groups.map do |comparate_group|
                  comparate_group.comparates.map do |comparate|
                    comparate.comparable_element.comparable.type1.name
                  end.join(', ')
                end
                row << if bac_comparison.is_anova
                         "[ID: #{bac_comparison.id}] ANOVA Comparison"
                       else
                         "[ID: #{bac_comparison.id}] [#{g1}] vs. [#{g2}]"
                       end
                row_style << @styles[bac_comparison_index % 4]
                all_measures.each do |measure|
                  exists, record_name = records_lookups["wacs_bacs_rssms-#{extraction.id}-#{eefpst1.type1_id}-#{eefpst1r.population_name.id}-#{wac_comparison.id}-#{bac_comparison.id}-#{measure.name}"]
                  row << record_name
                  row_style << (exists ? @styles[bac_comparison_index % 4] : nil)
                end
              end

              sheet.add_row(row, style: row_style)
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
      extraction.user&.profile&.username || '*missing profile username*',
      extraction.citations_project.citation.id,
      extraction.citations_project.citation.name,
      extraction.citations_project.refman,
      extraction.citations_project.other_reference,
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

  def create_email_export(filename)
    export_type = ExportType.find_by(name: '.xlsx')
    exported_item = ExportedItem.create!(project: @project, user_email: @user_email, export_type:)
    exported_item.file.attach(io: File.open(filename), filename:)
    raise 'Cannot attach exported file' unless exported_item.file.attached?

    exported_item.external_url = exported_item.download_url
    exported_item.save!
    exported_item
  end

  def ensure_unique_sheet_name(name)
    counter = 0
    candidate_name = name
    WORKSHEET_NAME_FORBIDDEN_CHARS.each do |c|
      candidate_name.delete!(c)
    end

    # Excel limits sheet name length to 31 characters
    candidate_name = limit_sheet_name_length(candidate_name, 31)

    while (@package.workbook.worksheets.any? do |worksheet|
             worksheet.name == candidate_name
           end) || RESERVED_WORKSHEET_NAMES.include?(candidate_name)
      counter += 1
      counter_length = counter.to_s.length
      candidate_name = candidate_name[0..(28 - (counter_length - 1))]
      candidate_name = "#{candidate_name}_#{counter}"
    end

    candidate_name
  end

  def limit_sheet_name_length(name, max_length)
    if name.length > max_length
      half_length = (max_length - 3) / 2
      first_part  = name[0, half_length]
      second_part = name[-half_length..-1]
      name = "#{first_part}...#{second_part}"
    end

    name
  end
end
