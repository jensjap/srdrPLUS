class ScreeningDataExportJob < ApplicationJob
  def perform(user_email, project_id)
    exported_item = ExportedItem.create!(project_id:, user_email:, export_type: ExportType.find_by(name: '.xlsx'))
    filename = 'tmp/screening_data_export_project_' + project_id.to_s + '_' + Time.now.strftime('%s') + '.xlsx'
    p = build_xlsx(project_id)
    raise 'Unable to serialize' unless p.serialize(filename)

    exported_item.file.attach(io: File.open(filename), filename:)

    raise 'Cannot attach exported file' unless exported_item.file.attached?

    exported_item.external_url = Rails.application.routes.default_url_options[:host] + Rails.application.routes.url_helpers.rails_blob_path(
      exported_item.file, only_path: true
    )
    exported_item.save!

    ExportMailer.notify_screening_data_export_completion(exported_item.id).deliver_later
  rescue StandardError => e
    ExportMailer.notify_screening_data_export_failure(user_email, project_id).deliver_later
    Sentry.capture_exception(e) if Rails.env.production?
  end

  def build_xlsx(project_id)
    p = Axlsx::Package.new
    wb = p.workbook
    project = Project.find(project_id)
    users = project.users.includes(:profile).map { |user| [user.id, user.handle.squeeze(' ')] }
    %w[AS FS].each do |screening_type|
      wb.add_worksheet(name: "#{screening_type} data by citations") do |sheet|
        headers = [
          'srdr citation id',
          'accession no',
          'authors',
          'title',
          'pub date',
          'abstract screening status',
          'fulltext screening status',
          'extraction status',
          'sub status',
          'consensus label',
          'consensus user name'
        ]
        users.each do |user|
          headers << "\"#{user[1]}\" Label"
        end
        headers << 'All User Tags'
        users.each do |user|
          headers << "\"#{user[1]}\" Reasons"
        end
        headers << 'Notes'
        headers = headers.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
        sheet.add_row(
          headers
        )

        mh = {}
        screening_results =
          case screening_type
          when 'AS'
            project.abstract_screening_results.includes(:tags, :reasons, user: :profile)
          when 'FS'
            project.fulltext_screening_results.includes(:tags, :reasons, user: :profile)
          end
        screening_results.each do |asr|
          mh[asr.citations_project_id] ||= {
            user_labels: {},
            user_reasons: {},
            notes: [],
            tags: [],
            consensus_label: nil,
            consensus_user: nil
          }
          mh[asr.citations_project_id][:user_labels][asr.user_id] = asr.label
          mh[asr.citations_project_id][:tags] += asr.tags.map(&:name)
          mh[asr.citations_project_id][:user_reasons][asr.user_id] = asr.reasons.join('; ')
          mh[asr.citations_project_id][:notes] << "#{asr.user.handle}: \"#{asr.notes}\"" unless asr.notes.blank?
        end

        CitationsProject.search(where: { project_id: project.id }, load: false).each do |cp|
          columns = [
            cp['citation_id'],
            cp['accession_number_alts'],
            cp['author_map_string'],
            cp['name'],
            cp['year'],
            cp['abstract_qualification'],
            cp['fulltext_qualification'],
            cp['extraction_qualification'],
            cp['screening_status']
          ]
          cp_id = cp.id.to_i
          columns << (mh.dig(cp_id, :consensus_label) || '')
          columns << (mh.dig(cp_id, :consensus_user) || '')
          users.each do |user|
            columns << (mh.dig(cp_id, :user_labels, user[0]) || '')
          end
          columns << ((mh.dig(cp_id, :tags) || []).uniq.join('; '))
          users.each do |user|
            columns << (mh.dig(cp_id, :user_reasons, user[0]) || '')
          end
          columns << ((mh.dig(cp_id, :notes) || []).uniq.join("\n"))

          columns = columns.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
          sheet.add_row(columns)
        end
      end
    end

    wb.add_worksheet(name: 'screening descriptions') do |sheet|
      sheet.add_row(
        [
          'screening phase',
          'screening system id',
          'type',
          'exclusive users',
          'if exclusive, user handles',
          'yes labels require tags',
          'no labels require tags',
          'maybe labels require tags',
          'no labels require reasons',
          'maybe labels require reasons',
          'yes labels require notes',
          'no labels require notes',
          'maybe labels require notes',
          'exclusive reasons',
          'exclusive tags',
          'hide author information',
          'hide journal information',
          'selected reasons',
          'selected tags'
        ].map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
      )

      project.abstract_screenings.includes(:reasons, :tags, users: :profile).each do |as|
        sheet.add_row(
          [
            'abstract',
            as.id,
            as.abstract_screening_type,
            as.exclusive_users,
            as.users.map(&:handle),
            as.yes_tag_required,
            as.no_tag_required,
            as.maybe_tag_required,
            as.no_reason_required,
            as.maybe_reason_required,
            as.yes_note_required,
            as.no_note_required,
            as.maybe_note_required,
            as.only_predefined_reasons,
            as.only_predefined_tags,
            as.hide_author,
            as.hide_journal,
            as.reasons.map(&:name),
            as.tags.map(&:name)
          ].map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
        )
      end
      project.fulltext_screenings.includes(:reasons, :tags, users: :profile).each do |fs|
        sheet.add_row(
          [
            'fulltext',
            fs.id,
            fs.fulltext_screening_type,
            fs.exclusive_users,
            fs.users.map(&:handle),
            fs.yes_tag_required,
            fs.no_tag_required,
            fs.maybe_tag_required,
            fs.no_reason_required,
            fs.maybe_reason_required,
            fs.yes_note_required,
            fs.no_note_required,
            fs.maybe_note_required,
            fs.only_predefined_reasons,
            fs.only_predefined_tags,
            fs.hide_author,
            fs.hide_journal,
            fs.reasons.map(&:name),
            fs.tags.map(&:name)
          ].map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
        )
      end
    end

    project.abstract_screenings.each do |as|
      wb.add_worksheet(name: "abstract screening id #{as.id}") do |sheet|
        headers = [
          'srdr citation id',
          'abstract screening type',
          'user',
          'label',
          'reasons',
          'tags',
          'notes'
        ]
        asf = ScreeningForm.find_or_create_by(project:, form_type: 'abstract')
        asf.sf_questions.each_with_index do |sf_question, q_index|
          sf_question.sf_rows.each_with_index do |sf_row, r_index|
            question_name = sf_row.name.blank? ? "Question #{q_index}" : sf_question.name
            row_name = sf_row.name.blank? ? "Row #{r_index}" : sf_row.name
            sf_question.sf_columns.each_with_index do |sf_column, c_index|
              column_name = sf_column.name.blank? ? "Column #{c_index}" : sf_column.name
              headers << "#{question_name}: #{row_name} / #{column_name}"
            end
          end
        end
        sheet.add_row(
          headers.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
        )
        as.abstract_screening_results.includes(:tags, :reasons, :citations_project, user: :profile).each do |asr|
          row = [
            asr.citations_project.citation_id,
            asr.abstract_screening.abstract_screening_type,
            asr.user.handle,
            asr.label,
            asr.reasons.map(&:name),
            asr.tags.map(&:name),
            asr.notes
          ]

          asf.sf_questions.each_with_index do |sf_question, _q_index|
            sf_question.sf_rows.each_with_index do |sf_row, _r_index|
              sf_question.sf_columns.each_with_index do |sf_column, _c_index|
                sf_cell = SfCell.find_by(sf_row:, sf_column:)
                if sf_cell.nil?
                  row << nil
                else
                  cell = "Answer Type: #{sf_cell.cell_type}"
                  sfars = SfAbstractRecord.where(sf_cell:, abstract_screening_result: asr)
                  sfos = sf_cell.sf_options
                  case sf_cell.cell_type
                  when SfCell::TEXT
                    cell += "\n"
                    cell += sfars.map(&:value).join('\n')
                  when SfCell::NUMERIC
                    sfars.each do |sfar|
                      cell += "\n"
                      cell += sfar.equality if sf_cell.with_equality
                      cell += sfar.value
                    end
                  when SfCell::CHECKBOX, SfCell::DROPDOWN, SfCell::RADIO
                    sfos.each do |sfo|
                      record = sfars.select { |sfar| sfar.value == sfo.name }.first
                      cell += "\n"
                      cell += "#{sfo.name}: #{record.nil? ? 'unselected' : 'selected'}"
                      cell += " [followup: #{record&.followup}]" if sfo.with_followup
                    end
                  when SfCell::SELECT_ONE, SfCell::SELECT_MULTIPLE
                    sfos.each do |sfo|
                      record = sfars.select { |sfar| sfar.value == sfo.name }.first
                      cell += "\n"
                      cell += "#{sfo.name}: #{record.nil? ? 'unselected' : 'selected'}"
                      cell += " [followup: #{record&.followup}]" if sfo.with_followup
                    end
                    sfars.select { |sfar| sfos.none? { |sfo| sfo.name == sfar.value } }.each do |sfar|
                      cell += "\n"
                      cell += "#{sfar.value}: selected"
                    end
                  end
                  row << cell
                end
              end
            end
          end

          sheet.add_row(row.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') })
        end
      end
    end

    project.fulltext_screenings.each do |fs|
      wb.add_worksheet(name: "fulltext screening id #{fs.id}") do |sheet|
        headers = [
          'srdr citation id',
          'fulltext screening type',
          'user',
          'label',
          'reasons',
          'tags',
          'notes'
        ]
        fsf = ScreeningForm.find_or_create_by(project:, form_type: 'fulltext')
        fsf.sf_questions.each_with_index do |sf_question, q_index|
          sf_question.sf_rows.each_with_index do |sf_row, r_index|
            question_name = sf_row.name.blank? ? "Question #{q_index}" : sf_question.name
            row_name = sf_row.name.blank? ? "Row #{r_index}" : sf_row.name
            sf_question.sf_columns.each_with_index do |sf_column, c_index|
              column_name = sf_column.name.blank? ? "Column #{c_index}" : sf_column.name
              headers << "#{question_name}: #{row_name} / #{column_name}"
            end
          end
        end
        sheet.add_row(
          headers.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
        )
        fs.fulltext_screening_results.includes(:tags, :reasons, :citations_project, user: :profile).each do |fsr|
          row = [
            fsr.citations_project.citation_id,
            fsr.fulltext_screening.fulltext_screening_type,
            fsr.user.handle,
            fsr.label,
            fsr.reasons.map(&:name),
            fsr.tags.map(&:name),
            fsr.notes
          ]

          fsf.sf_questions.each_with_index do |sf_question, _q_index|
            sf_question.sf_rows.each_with_index do |sf_row, _r_index|
              sf_question.sf_columns.each_with_index do |sf_column, _c_index|
                sf_cell = SfCell.find_by(sf_row:, sf_column:)
                if sf_cell.nil?
                  row << nil
                else
                  cell = "Answer Type: #{sf_cell.cell_type}"
                  sffrs = SfFulltextRecord.where(sf_cell:, fulltext_screening_result: fsr)
                  sfos = sf_cell.sf_options
                  case sf_cell.cell_type
                  when SfCell::TEXT
                    cell += "\n"
                    cell += sffrs.map(&:value).join('\n')
                  when SfCell::NUMERIC
                    sffrs.each do |sffr|
                      cell += "\n"
                      cell += sffr.equality if sf_cell.with_equality
                      cell += sffr.value
                    end
                  when SfCell::CHECKBOX, SfCell::DROPDOWN, SfCell::RADIO
                    sfos.each do |sfo|
                      record = sffrs.select { |sffr| sffr.value == sfo.name }.first
                      cell += "\n"
                      cell += "#{sfo.name}: #{record.nil? ? 'unselected' : 'selected'}"
                      cell += " [followup: #{record&.followup}]" if sfo.with_followup
                    end
                  when SfCell::SELECT_ONE, SfCell::SELECT_MULTIPLE
                    sfos.each do |sfo|
                      record = sffrs.select { |sffr| sffr.value == sfo.name }.first
                      cell += "\n"
                      cell += "#{sfo.name}: #{record.nil? ? 'unselected' : 'selected'}"
                      cell += " [followup: #{record&.followup}]" if sfo.with_followup
                    end
                    sffrs.select { |sffr| sfos.none? { |sfo| sfo.name == sffr.value } }.each do |sffr|
                      cell += "\n"
                      cell += "#{sffr.value}: selected"
                    end
                  end
                  row << cell
                end
              end
            end
          end

          sheet.add_row(row.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') })
        end
      end
    end

    p
  end
end
