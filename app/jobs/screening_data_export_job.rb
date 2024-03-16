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
    @users = project.users.includes(:profile).map { |user| [user.id.to_i, user.handle.squeeze(' ')] }
    @consensus_dict = build_consensus_dict(project)

    %w[AS FS].each do |screening_type|
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
          user_reasons: [],
          notes: [],
          tags: [],
          consensus_label: nil,
          consensus_user: nil,
          consensus_tags: nil,
          consensus_reasons: nil,
          consensus_notes: nil,
          sr_label_dates: []
        }
        if sr.privileged
          unless sr.label.blank?
            mh[sr.citations_project_id][:consensus_label] = sr.label
            mh[sr.citations_project_id][:consensus_user] = sr.user.handle
            mh[sr.citations_project_id][:consensus_tags] = sr.tags.map(&:name).join('||')
            mh[sr.citations_project_id][:consensus_reasons] = sr.reasons.map(&:name).join('||')
            mh[sr.citations_project_id][:consensus_notes] = sr.notes
          end
        else
          mh[sr.citations_project_id][:user_labels][sr.user_id] = sr.label
          mh[sr.citations_project_id][:tags] += sr.tags.map(&:name)
          mh[sr.citations_project_id][:user_reasons] += sr.reasons.map(&:name)
          mh[sr.citations_project_id][:notes] += [sr.notes] unless sr.notes.blank?
          mh[sr.citations_project_id][:sr_label_dates] << sr.updated_at
        end
      end

      # New label export structure: Sheet 1
      wb.add_worksheet(name: "#{ screening_type } Long") do |sheet|
        sf = case screening_type
             when 'AS'
               ScreeningForm.find_or_create_by(project:, form_type: 'abstract')
             when 'FS'
               ScreeningForm.find_or_create_by(project:, form_type: 'fulltext')
             end
        sheet = build_headers_and_add_to_sheet(sheet, project, 'sheet1', sf)
        srs = case screening_type
              when 'AS'
                AbstractScreeningResult
              .includes(:tags, :reasons, user: :profile)
              .joins(:citations_project)
              .where(citations_project: { project: })
              when 'FS'
                FulltextScreeningResult
              .includes(:tags, :reasons, user: :profile)
              .joins(:citations_project)
              .where(citations_project: { project: })
              end
        srs.each do |sr|
          cp = sr.citations_project
          citation = cp.citation
          row = [
            citation.id,
            citation.accession_number,
            citation.pmid,
            cp.refman,
            "#{ citation.journal&.name } #{ citation.journal&.volume }(#{ citation.journal&.issue }):#{ citation&.page_number_start }-#{ citation&.page_number_end }",
            citation.doi,
            citation.keywords.map(&:name).join(', '),
            sr.updated_at,
            cp.screening_status,
            @consensus_dict[screening_type][cp.id],
            sr.privileged ? 'Adjudicator' : sr.user.handle,
            sr.label,
            sr.reasons.map(&:name).join('||'),
            sr.tags.map(&:name).join('||'),
            sr.notes
          ]

          # Add screening form answers to row.
          sf.sf_questions.each_with_index do |sf_question, _q_index|
            sf_question.sf_rows.each_with_index do |sf_row, _r_index|
              sf_question.sf_columns.each_with_index do |sf_column, _c_index|
                sf_cell = SfCell.find_by(sf_row:, sf_column:)
                if sf_cell.nil?
                  row << nil
                else
                  cell = ''
                  sfrs = case screening_type
                         when 'AS'
                           SfAbstractRecord.where(sf_cell:, abstract_screening_result: sr)
                         when 'FS'
                           SfFulltextRecord.where(sf_cell:, fulltext_screening_result: sr)
                         end
                  sfos = sf_cell.sf_options
                  case sf_cell.cell_type
                  when SfCell::TEXT
                    cell += sfrs.map(&:value).join('\n')
                  when SfCell::NUMERIC
                    sfrs.each_with_index do |sfr, idx|
                      cell += "\n" if idx > 0
                      cell += sfr.equality.to_s if sf_cell.with_equality
                      cell += sfr.value.to_s
                    end
                  when SfCell::CHECKBOX, SfCell::DROPDOWN, SfCell::RADIO, SfCell::SELECT_ONE, SfCell::SELECT_MULTIPLE
                    sfrs.each_with_index do |sfr, idx|
                      cell += "\n" if idx.positive?
                      sfo = sfos.select { |sfo| sfo.name == sfr.value }.first
                      cell += "#{sfr.value}"
                      cell += ": #{sfr.followup}" if sfo&.with_followup
                    end
                  end
                  row << cell&.strip
                end
              end
            end
          end
          sheet.add_row(
            row.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
          )
        end
      end

      # New label export structure: Sheet 2
      wb.add_worksheet(name: "#{ screening_type } Wide Brief") do |sheet|
        sf = case screening_type
             when 'AS'
               ScreeningForm.find_or_create_by(project:, form_type: 'abstract')
             when 'FS'
               ScreeningForm.find_or_create_by(project:, form_type: 'fulltext')
             end
        sheet = build_headers_and_add_to_sheet(sheet, project, 'sheet2', sf)
        CitationsProject.search(where: { project_id: project.id }, load: false).each do |cp|
          cp_id = cp.id.to_i
          columns = [
            cp['citation_id'],
            cp['accession_number'],
            cp['pmid'],
            cp['refman'],
            cp['publication'],
            cp['doi'],
            cp['keywords'],
          ]
          last_label_time = mh.dig(cp_id, :sr_label_dates)&.max&.in_time_zone(@desired_time_zone)
          columns << last_label_time
          columns << cp['screening_status']
          columns << @consensus_dict[screening_type][cp_id]
          @users.each do |user|
            columns << mh.dig(cp_id, :user_labels, user[0])
          end
          tags = if mh.dig(cp_id, :consensus_label).present?
                   mh.dig(cp_id, :consensus_tags)
                 else
                   mh.dig(cp_id, :tags)&.uniq&.join('||')
                 end
          columns << tags
          reasons = if mh.dig(cp_id, :consensus_label).present?
                      mh.dig(cp_id, :consensus_reasons)
                    else
                      mh.dig(cp_id, :user_reasons)&.uniq&.join('||')
                    end
          columns << reasons
          notes = if mh.dig(cp_id, :consensus_label).present?
                    mh.dig(cp_id, :consensus_notes)
                  else
                    mh.dig(cp_id, :notes)&.uniq&.join('||')
                  end
          columns << notes

          # Add screening form answers to row compressed layout:
          #   If consolidated sr exists and answer value is present,
          #   then use it, else use all other non-consolidated unique
          #   answer values.
          columns += add_compressed_screening_form_answers(cp, screening_type, sf)

          sheet.add_row(
            columns.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
          )
        end
      end
    end

    p
  rescue => e
    Sentry.capture_exception(e) if Rails.env.production?
    debugger if Rails.env.development?
  end

  private

  def add_compressed_screening_form_answers(cp, screening_type, sf)
    citations_project = CitationsProject.find(cp.id.to_i)
    sf_answers = {}
    sf_answers[:cells] = {}
    columns = []
    srs = case screening_type
          when 'AS'
            AbstractScreeningResult
          .includes(:tags, :reasons, user: :profile)
          .joins(:citations_project)
          .where(citations_project:)
          .order(privileged: :asc)
          when 'FS'
            FulltextScreeningResult
          .includes(:tags, :reasons, user: :profile)
          .joins(:citations_project)
          .where(citations_project:)
          .order(privileged: :asc)
          end
    sf.sf_questions.each_with_index do |sf_question, _q_index|
      sf_question.sf_rows.each_with_index do |sf_row, _r_index|
        sf_question.sf_columns.each_with_index do |sf_column, _c_index|
          sf_cell = SfCell.find_by(sf_row:, sf_column:)
          if sf_cell.nil?
            columns << nil
          else
            sf_answers[:cells][sf_cell.id] = [] unless sf_answers[:cells].keys.include?(sf_cell.id)
            srs.each do |sr|
              cell = ''
              sfrs = case screening_type
                     when 'AS'
                       SfAbstractRecord.where(sf_cell:, abstract_screening_result: sr)
                     when 'FS'
                       SfFulltextRecord.where(sf_cell:, fulltext_screening_result: sr)
                     end
              sfos = sf_cell.sf_options
              case sf_cell.cell_type
              when SfCell::TEXT
                sf_answers[:cells][sf_cell.id] += sfrs.map(&:value) if sfrs.map(&:value).any?(&:present?)
                sf_answers[:cells][sf_cell.id] = sfrs.map(&:value) if sr.privileged && sfrs.map(&:value).any?(&:present?)

              when SfCell::NUMERIC
                sfrs.each_with_index do |sfr, idx|
                  cell += sfr.equality.to_s if sf_cell.with_equality
                  cell += sfr.value.to_s
                end
                sf_answers[:cells][sf_cell.id] += [cell] if cell.present?
                sf_answers[:cells][sf_cell.id] = [cell] if sr.privileged && cell.present?
              when SfCell::CHECKBOX, SfCell::DROPDOWN, SfCell::RADIO, SfCell::SELECT_ONE, SfCell::SELECT_MULTIPLE
                sfrs.each_with_index do |sfr, idx|
                  sfo = sfos.select { |sfo| sfo.name == sfr.value }.first
                  cell += "#{sfr.value}"
                  cell += ": #{sfr.followup}" if sfo&.with_followup
                end
                sf_answers[:cells][sf_cell.id] += [cell] if cell.present?
                sf_answers[:cells][sf_cell.id] = [cell] if sr.privileged && cell.present?
              end
            end
          end

          columns << sf_answers[:cells][sf_cell.id].flatten(1).reject(&:empty?).map(&:strip).uniq.join('||')
        end
      end
    end

    columns
  end

  def build_headers_and_add_to_sheet(sheet, project, style, sf=nil)
    headers = [
      'SRDR Citation ID',
      'Accession Number',
      'PMID',
      'RefId',
      'Publication String',
      'DOI',
      'Keywords',
      'Last Label Time',
      'Sub Status',
    ]
    case style
    when 'sheet1'
      headers.concat [
        'Consensus Label',
        'Username',
        'User Label',
        'Reasons',
        'Tags',
        'Notes',
      ]
      sf.sf_questions.each_with_index do |sf_question, q_index|
        question_name = sf_question.name.blank? ? "Question #{q_index}" : sf_question.name
        if sf_question.sf_rows.size.eql?(1) && sf_question.sf_columns.size.eql?(1)
          headers << question_name.to_s
        else
          sf_question.sf_rows.each_with_index do |sf_row, r_index|
            row_name = sf_row.name.blank? ? "Row #{r_index}" : sf_row.name
            sf_question.sf_columns.each_with_index do |sf_column, c_index|
              column_name = sf_column.name.blank? ? "Column #{c_index}" : sf_column.name
              headers << "#{question_name}: #{row_name} / #{column_name}"
            end
          end
        end
      end
    when 'sheet2'
      headers.concat [
        'Concensus Label',
      ]
      @users.each do |user|
        headers << "\"#{user[1]}\" Label"
      end
      headers << 'Tags'
      headers << 'Reasons'
      headers << 'Notes'
      sf.sf_questions.each_with_index do |sf_question, q_index|
        question_name = sf_question.name.blank? ? "Question #{q_index}" : sf_question.name
        if sf_question.sf_rows.size.eql?(1) && sf_question.sf_columns.size.eql?(1)
          headers << "#{ question_name.to_s }"
        else
          sf_question.sf_rows.each_with_index do |sf_row, r_index|
            row_name = sf_row.name.blank? ? "Row #{r_index}" : sf_row.name
            sf_question.sf_columns.each_with_index do |sf_column, c_index|
              column_name = sf_column.name.blank? ? "Column #{c_index}" : sf_column.name
              headers << "#{question_name}: #{row_name} / #{column_name}"
            end
          end
        end
      end
    end
    sheet.add_row(
      headers.map { |cell| cell.to_s.gsub(/\p{Cf}/, '') }
    )

    sheet
  end

  # Consensus label key:
  #   x -> unresolved conflict
  #   o -> incomplete
  #   1 -> accepted
  #   0 -> maybe
  #  -1 -> rejected
  #
  # return { :citations_project_id => consensus_label }
  def build_consensus_dict(project)
    consensus_dict = {}
    %w[AS FS].each do |screening_type|
      consensus_dict[screening_type] = {}
      project.citations_projects.each do |citations_project|
        consensus_dict[screening_type][citations_project.id] = nil
        priv_srs =
          case screening_type
          when 'AS'
            AbstractScreeningResult.where(citations_project:, privileged: true)
          when 'FS'
            FulltextScreeningResult.where(citations_project:, privileged: true)
          end
        if priv_srs.size > 1
          Sentry.capture_exception('Screening Data Export Error: priv_srs.size > 1') if Rails.env.production?
          debugger if Rails.env.development?
        end
        priv_sr = priv_srs.first
        # Privileged label is prioritized.
        if priv_sr.present? && [-1, 1].include?(priv_sr.label)
          consensus_dict[screening_type][citations_project.id] = priv_sr.label
        # If no privileged label exists then we check privileged: false labels.
        else
          srs =
            case screening_type
            when 'AS'
              AbstractScreeningResult.where(citations_project:, privileged: false)
            when 'FS'
              FulltextScreeningResult.where(citations_project:, privileged: false)
            end
          case srs.size
          when 0
            consensus_dict[screening_type][citations_project.id] = nil
          when 1
            sr = srs.first
            screening =
              case screening_type
              when 'AS'
                sr.abstract_screening
              when 'FS'
                sr.fulltext_screening
              end
            consensus_dict[screening_type][citations_project.id] =
              case screening.screening_type
              when /single/i
                sr.label
              when /double|expert/i
                'o'
              when /pilot/i
                # Check how many users are assigned in case of exclusive_users.
                if screening.exclusive_users
                  screening.users.size.eql?(1) ? sr.label : 'o'
                # Otherwise look for project.members size to determine 'o' status.
                else
                  project.members.size.eql?(1) ? sr.label : 'o'
                end
              end
          else
            sr = srs.first
            consensus_dict[screening_type][citations_project.id] =
              case srs.map(&:label).reject(&:blank?).uniq.size
              when 1
                srs.any? { |sr| sr.label == 0 } ? 'x' : sr.label
              else
                'x'
              end
          end
        end
      end
    end

    consensus_dict
  end

  # Consensus label key:
  #   x -> unresolved conflict
  #   o -> incomplete
  #   1 -> accepted
  #  -1 -> rejected
  #
  #  System prioritizes in the following order:
  #  1. Screening Qualifications
  #  2. [A,F]SR (where privileged: true) also known as Consensus Label
  #  3. [A,F]SR (where privileged: false) also known as Labels
  #
  # return { :user_id => :label }
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
    debugger if Rails.env.development?
  end
end
