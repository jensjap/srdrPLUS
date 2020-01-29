class DistillerImporter
  def initialize(project, user)
    @user = user
    @project = project
    @projects_users_role = ProjectsUsersRole.find_or_create_by!(
                                      projects_user: ProjectsUser.find_or_create_by!(project: @project, user: @user),
                                      role: Role.find_by( name: 'Leader'))

    # We want to save distiller user reference as another question, and we want to create a separate kq for that
    user_info_kq = KeyQuestion.find_or_create_by!(name: "Imported User Info")
    @user_info_kqp = KeyQuestionsProject.find_or_create_by!(key_question: user_info_kq, project: @project)
    @efps_position = 1
  end

  def add_t2_section(imported_file)
    # TODO => Check filetype and importtype and return if wrong

    csv_content = CSV.parse(imported_file.content.download.gsub /\r/, '')

    #efps_hash = create_efps_hash csv_content.first, kq_hash, imported_file.section.name
    #@project_json["project"]["extraction_forms"][@ef_id]["sections"][imported_file.section.id] = efps_hash

    efps = import_efps(imported_file.section, @efps_position)

    header = csv_content[0]

    #q_i = 1
    #headers.each_with_index do |h,i|
    #  if [0,1,2].include? i
    #    next
    #  end
    #  # ordering is the same as the order in the header
    #  kq = imported_file.key_question
    #  kqp = KeyQuestionsProject.find_or_create_by key_question: kq, project: @project
    #  qrcf_id_map[i] = import_question(efps, h, kqp, i-2)

    #  q_i += 1
    #end
    kq = imported_file.key_question
    kqp = KeyQuestionsProject.find_or_create_by key_question: kq, project: @project

    q_piece_arr = build_questions efps, header, kqp

    csv_content[1..csv_content.length].each do |row|
      import_extraction(row, @projects_users_role, efps, q_piece_arr)
    end

    # next section to be added will be placed after this one
    @efps_position += 1
  end

  def import_extraction(row, pur, efps, q_piece_arr)
    c_arr = Citation.where( refman: row[0] )
    cp = CitationsProject.where( project: @project, citation: c_arr ).first

    if cp.nil?
      raise "Citation Not Found"
      return
    end

    e = Extraction.find_or_create_by! project: @project, projects_users_role: pur, citations_project: cp

    checkbox_ans_arr = []
    prev_qrcf = nil

    row.each_with_index do |cell, i|
      if [0,2].include? i
        next
      end
      if i == 1
        q_piece = q_piece_arr.first
      else
        q_piece = q_piece_arr[i-2]
      end
      if q_piece.class.name == "QuestionRowColumnField"
        qrcf = q_piece
        eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by!( extraction: e, extraction_forms_projects_section: efps )
        eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                                        extractions_extraction_forms_projects_sections_type1: nil,
                                                                                                        question_row_column_field: qrcf
        Record.find_or_create_by! recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                  recordable_id: eefpsqrcf.id,
                                  name: (cell || "")

      elsif cell != nil and cell != ""
        qrcf = q_piece.question.question_rows.first.question_row_columns.first.question_row_column_fields.first
        if prev_qrcf == nil then prev_qrcf = qrcf end
        if qrcf != prev_qrcf
          eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by!( extraction: e, extraction_forms_projects_section: efps )
          eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                                          extractions_extraction_forms_projects_sections_type1: nil,
                                                                                                          question_row_column_field: prev_qrcf
          Record.find_or_create_by! recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                    recordable_id: eefpsqrcf.id,
                                    name: ('["' + checkbox_ans_arr.join('", "') + '"]')
          prev_qrcf = qrcf
          checkbox_ans_arr = []
        end
        checkbox_ans_arr << q_piece.id
      end
    end

    if not prev_qrcf.nil?
      eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by!( extraction: e, extraction_forms_projects_section: efps )
      eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                                      extractions_extraction_forms_projects_sections_type1: nil,
                                                                                                      question_row_column_field: prev_qrcf
      Record.find_or_create_by! recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                recordable_id: eefpsqrcf.id,
                                name: ('["' + checkbox_ans_arr.join('", "') + '"]')
    end
  end


  def import_efps(s, position)
    #do we want to create sections that does not exist? -Birol
    efps_type = ExtractionFormsProjectsSectionType.find_by! name: 'Type 2'


    # ALLOW MULTIPLE EFPSs WITH THE SAME SECTION
    efps = ExtractionFormsProjectsSection.create! extraction_forms_project: @project.extraction_forms_projects.first,
                                                     extraction_forms_projects_section_type: efps_type,
                                                     section: s
    efps.ordering.position = position

    ExtractionFormsProjectsSectionOption.create! extraction_forms_projects_section: efps,
                                                 by_type1: false,
                                                 include_total: false
    return efps
  end

  def import_question(efps, qname, kqp, qrct)
    q = Question.create extraction_forms_projects_section: efps,
                        name: qname,
                        description: ""

    KeyQuestionsProjectsQuestion.find_or_create_by! key_questions_project: kqp,
                                                    question: q

    qr = QuestionRow.find_by!(question: q)
    qrc_type = QuestionRowColumnType.find_by! name: qrct
    qrc = QuestionRowColumn.find_by! question_row: qr
    qrc.update! question_row_column_type: qrc_type,
                name: ""

    return q
  end

  def build_questions(efps, header, kqp)
    q_piece_arr = []
    current_question = nil
    header.each_with_index do |cell, i|
      if [0,2].include? i
        next
      elsif i == 1
      #  current_question = import_question efps, cell, kqp, "text"
      #  q_piece_arr << current_question.question_rows.first.question_row_columns.first.question_row_column_fields.first
      #  next
        q = import_question(efps, "Extractor Username", @user_info_kqp, "text")
        q_piece_arr << q.question_rows.first.question_row_columns.first.question_row_column_fields.first
        next
      end

      if cell.match(/_comment$/)
        #question_arr.last[:question_rows] << {name: "Comment:", question_row_columns: [{question_row_column_type_id: 1}]}
        q_piece_arr << add_comment_to_text_question(current_question).question_row_columns.first.question_row_column_fields.first
      elsif cell.match(/\n\n -> /)
        cell_parts = cell.strip.split(/\n\n -> /)
        if cell_parts.length > 2
          # ????
          q_piece_arr << nil
        else
          if cell_parts.first == current_question.name
            #question_arr.last[:question_rows].first[:question_row_columns].first[:question_row_columns_question_row_column_options] << {name: cell_parts.second, question_row_column_option_id: 1}
            if cell_parts.second.match(/ \(COMMENT\)$/)
              #question_arr.last[:question_rows] << {name: cell_parts.second, question_row_columns: [{question_row_column_type_id: 1}]}
              qr = add_comment_to_checkbox_question(current_question, cell_parts.second)
              q_piece_arr << qr.question_row_columns.first.question_row_column_fields.first
            else
              qrcqrco = add_option_to_checkbox_question(current_question, cell_parts.second)
              q_piece_arr << qrcqrco
            end
          else
            #question_arr << { question_rows: [{question_row_columns: [{question_row_columns_question_row_column_options: [],question_row_column_type_id: 5}]}], name: cell }
            current_question = import_question efps, cell_parts.first, kqp, "checkbox"
            qrcqrco = add_option_to_checkbox_question(current_question, cell_parts.second)
            q_piece_arr << qrcqrco
          end
        end
      else
        #question_arr << { question_rows: [{question_row_columns: [{question_row_column_type_id: 1}]}], name: cell }
        current_question = import_question efps, cell.strip, kqp, "text"
        q_piece_arr << current_question.question_rows.first.question_row_columns.first.question_row_column_fields.first
      end
    end
    return q_piece_arr
  end

  def create_question(efps, name, qrct_id)
    q = Question.create(extraction_forms_projects_section: efps, name: name)
    q.question_rows.first.question_row_columns.first.question_row_column_type_id = qrct_id
    return q
  end

  def add_option_to_checkbox_question(q, option_name)
    qrc = q.question_rows.first.question_row_columns.first
    empty_qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_by(question_row_column: qrc, question_row_column_option_id: 1, name: "")
    if empty_qrcqrco.present?
      empty_qrcqrco.update name: option_name
      return empty_qrcqrco
    else
      return QuestionRowColumnsQuestionRowColumnOption.create(name: option_name,
                                                              question_row_column: qrc,
                                                              question_row_column_option_id: 1)
    end
  end

  def add_comment_to_text_question(q)
    qr = QuestionRow.create(question: q, name: "Comment:")
    qr.question_row_columns.first.question_row_column_type_id = 1
    return qr
  end

  def add_comment_to_checkbox_question(q, option_text)
    qr = QuestionRow.create(question: q, name: option_text)
    qr.question_row_columns.first.question_row_column_type_id = 1
    return qr
  end
end
