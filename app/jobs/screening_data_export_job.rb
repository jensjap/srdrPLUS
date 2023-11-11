class ScreeningDataExportJob < ApplicationJob
  def perform(user_email, project_id)
    export_user = User.find_by(email: user_email)
    @desired_time_zone = export_user.profile.time_zone
    exported_item = ExportedItem.create!(project_id:, user_email:, export_type: ExportType.find_by(name: '.xlsx'))
    filename = 'tmp/screening_data_export_project_' + project_id.to_s + '_' + Time.now.strftime('%s') + '.xlsx'
    p = build_xlsx(project_id)
    raise 'Unable to serialize' unless p.serialize(filename)

    exported_item.file.attach(io: File.open(filename), filename:)

    raise 'Cannot attach exported file' unless exported_item.file.attached?

    exported_item.external_url = exported_item.download_url
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
          'Srdr Citation ID',
          'Accession No',
          'Authors',
          'Title',
          'Abstract',
          'Pub Date',
          'Abstract Screening Status',
          'Fulltext Screening Status',
          'Extraction Status',
          'Sub Status',
          'Publication',
          'Doi',
          'Keywords',
          'Date First Screened',
          'Consensus Label'
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
        screening_results.each do |sr|
          mh[sr.citations_project_id] ||= {
            user_labels: {},
            user_reasons: {},
            notes: [],
            tags: [],
            consensus_label: nil,
            consensus_user: nil,
            sr_label_dates: []
          }
          if sr.privileged
            if !sr.label.blank?
              mh[sr.citations_project_id][:consensus_label] = sr.label
              mh[sr.citations_project_id][:consensus_user] = sr.user.handle
            end
          else
            mh[sr.citations_project_id][:user_labels][sr.user_id] = sr.label
            mh[sr.citations_project_id][:tags] += sr.tags.map(&:name)
            mh[sr.citations_project_id][:user_reasons][sr.user_id] = sr.reasons.map(&:name).join('; ')
            mh[sr.citations_project_id][:notes] << "#{sr.user.handle}: \"#{sr.notes}\"" unless sr.notes.blank?
            mh[sr.citations_project_id][:sr_label_dates] << sr.created_at
          end
        end

        CitationsProject.search(where: { project_id: project.id }, load: false).each do |cp|
          columns = [
            cp['citation_id'],
            cp['accession_number_alts'],
            cp['author_map_string'],
            cp['name'],
            cp['abstract'],
            cp['year'],
            cp['abstract_qualification'],
            cp['fulltext_qualification'],
            cp['extraction_qualification'],
            cp['screening_status'],
            cp['publication'],
            cp['doi'],
            cp['keywords']
          ]
          screening_status =
            case screening_type
            when 'AS'
              cp['abstract_qualification']
            when 'FS'
              cp['fulltext_qualification']
            end
          cp_id = cp.id.to_i
          first_screened_date = mh.dig(cp_id, :sr_label_dates)&.min
          columns << (
            if first_screened_date.present?
              first_screened_date.in_time_zone(@desired_time_zone)
            else
              ''
            end
          )
          columns << _calculate_consensus_column_value(
            mh.dig(cp_id, :consensus_label),
            mh.dig(cp_id, :user_labels),
            screening_status
          )
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
          'hide author information',
          'hide journal information',
          'reasons',
          'tags'
        ].map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
      )

      project.abstract_screenings.includes({ users: :profile,
                                             project: { projects_tags: :tag, projects_reasons: :reason } }).each do |as|
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
            as.hide_author,
            as.hide_journal,
            as.project.reasons.map(&:name),
            as.project.tags.map(&:name)
          ].map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
        )
      end
      project.fulltext_screenings.includes(users: :profile).each do |fs|
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
            fs.hide_author,
            fs.hide_journal,
            fs.project.reasons.map(&:name),
            fs.project.tags.map(&:name)
          ].map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
        )
      end
    end

    project.abstract_screenings.each do |as|
      wb.add_worksheet(name: "abstract screening id #{as.id}") do |sheet|
        headers = [
          'srdr citation id',
          'publication',
          'doi',
          'keywords',
          'created at',
          'abstract screening type',
          'user',
          'label',
          'reasons',
          'tags',
          'notes',
          'privileged'
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
          publication = ''
          doi = ''
          keywords = ''
          CitationsProject.search(where: { citation_id: asr.citations_project.citation_id }, load: false).each do |cp|
            publication = cp['publication']
            doi = cp['doi']
            keywords = cp['keywords']
          end

          row = [
            asr.citations_project.citation_id,
            publication,
            doi,
            keywords,
            asr.created_at,
            asr.abstract_screening.abstract_screening_type,
            asr.user.handle,
            asr.label,
            asr.reasons.map(&:name),
            asr.tags.map(&:name),
            asr.notes,
            asr.privileged
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
                      cell += sfar.equality.to_s if sf_cell.with_equality
                      cell += sfar.value.to_s
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
          'publication',
          'doi',
          'keywords',
          'created at',
          'fulltext screening type',
          'user',
          'label',
          'reasons',
          'tags',
          'notes',
          'privileged'
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
          publication = ''
          doi = ''
          keywords = ''
          CitationsProject.search(where: { citation_id: fsr.citations_project.citation_id }, load: false).each do |cp|
            publication = cp['publication']
            doi = cp['doi']
            keywords = cp['keywords']
          end

          row = [
            fsr.citations_project.citation_id,
            publication,
            doi,
            keywords,
            fsr.created_at,
            fsr.fulltext_screening.fulltext_screening_type,
            fsr.user.handle,
            fsr.label,
            fsr.reasons.map(&:name),
            fsr.tags.map(&:name),
            fsr.notes,
            fsr.privileged
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

  private

  # Consensus label key:
  #   x -> unresolved conflict
  #   o -> incomplete
  #   1 -> accepted
  #  -1 -> rejected

  #  System prioritizes in the following order:
  #  1. Screening Qualifications
  #  2. [A,F]SR (where privileged: true) also known as Consensus Label
  #  3. [A,F]SR (where privileged: false) also known as Labels
  #
  #  { :user_id => :label }
  def _calculate_consensus_column_value(consensus_label, user_labels, screening_qualification)
    dict_screening_qualification = { 'Passed' => 1, 'Rejected' => -1 }
    labels = user_labels&.values

    # If no labels exist at all then we return 'o' unless manual pro/de-motion occurred.
    # If there was a manual pro/de-motion then we use it instead to populate consensus
    # label column.
    if labels.blank?
      if dict_screening_qualification.keys.include?(screening_qualification)
        return dict_screening_qualification[screening_qualification]
      else
        return 'o'
      end
    end

    # If consensus label exists that is not 'x', then we return it to populate consensus
    # label column.
    return consensus_label if consensus_label.present? && !consensus_label.eql?('x')

    # Screening Qualification exists.
    if dict_screening_qualification.keys.include?(screening_qualification)
      # The system considers this citation to be done with the current
      # phase (i.e. 'AS', 'FS', 'Extraction'). This means that 'o' incomplete
      # is not an option.
      if labels.size.eql?(1)
        labels[0]
      elsif labels.uniq.length.eql?(1)
        labels[0]
      else
        'x'
      end

    # No Screening Qualification exists.
    else
      # Since no Screening Qualification exists, the presence of a single label must
      # mean that we are waiting for a second opinion. Thus screening is incomplete.
      if labels.size.eql?(1)
        'o'
      elsif labels.uniq.length.eql?(1)
        labels[0]
      elsif labels.any?(&:blank?)
        'o'
      else
        'x'
      end
    end

  rescue StandardError => e
    Sentry.capture_exception(e) if Rails.env.production?
    '?'

  end
end
