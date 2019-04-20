class DistillerImporter
  def initialize(project, user)
    @user = user
    @project = project
    pu = ProjectsUser.find_or_create_by!( project: @project, user: @user )
    @projects_users_role = ProjectsUsersRole.find_or_create_by!( projects_user: pu, role: Role.find_by( name: 'Importer' ) )
    kq = KeyQuestion.find_or_create_by!( name: "FAKE KEY QUESTION")
    @kqp = KeyQuestionsProject.find_or_create_by!( key_question: kq, project: @project )
    user_info_kq = KeyQuestion.find_or_create_by!( name: "Imported User Info" )
    @user_info_kqp = KeyQuestionsProject.find_or_create_by!( key_question: user_info_kq, project: @project )
    @efps_position = 1
  end

  def add_t2_section(imported_file)
    qrcf_id_map = {}
    # TODO => Check filetype and importtype and return if wrong
    # TODO => KEY QUESTION STUFF DOES NOT WORK

    csv_content = CSV.parse(imported_file.content.gsub /\r/, '')

    #efps_hash = create_efps_hash csv_content.first, kq_hash, imported_file.section.name
    #@project_json["project"]["extraction_forms"][@ef_id]["sections"][imported_file.section.id] = efps_hash

    efps = import_efps(imported_file.section, @efps_position)

    headers=csv_content[0]

    headers.each_with_index do |h,i|
      if [0,1,2].include? i
        next
      end
      # ordering is the same as the order in the header
      qrcf_id_map[i] = import_question(efps, h, @kqp, i-2)
    end
    qrcf_id_map[1] = import_question(efps, "Extractor Username", @user_info_kqp, headers.length-2)

    csv_content[1..csv_content.length].each do |row|
      import_extraction(row, @projects_users_role, efps, qrcf_id_map)
    end
  end

  def import_extraction(row, pur, efps, qrcf_id_map)
    c_arr = Citation.where( refman: row[0] )
    cp = CitationsProject.where( project: @project, citation: c_arr ).first
    e = Extraction.find_or_create_by! project: @project, projects_users_role: pur, citations_project: cp

    row.each_with_index do |cell, i|
      if [0,2].include? i
        next
      end
      qrcf = qrcf_id_map[i]
      eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by!( extraction: e, extraction_forms_projects_section: efps )
      eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by! extractions_extraction_forms_projects_section: eefps,
                                                                                                      extractions_extraction_forms_projects_sections_type1: nil,
                                                                                                      question_row_column_field: qrcf
      Record.find_or_create_by! recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                recordable_id: eefpsqrcf.id,
                                name: (cell || "")

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

    # ????????
    ExtractionFormsProjectsSectionOption.create! extraction_forms_projects_section: efps,
                                                 by_type1: nil,
                                                 include_total: nil
    return efps
  end

  def import_question(efps, qname, kqp, position)
    q = Question.create! extraction_forms_projects_section: efps,
                         name: qname,
                         description: ""

    q.ordering.position = position

    KeyQuestionsProjectsQuestion.find_or_create_by! key_questions_project: kqp,
                                                    question: q

    qr = QuestionRow.find_by!(question: q)
    qrc_type = QuestionRowColumnType.find_by! name: "Text"
    qrc = QuestionRowColumn.find_by! question_row: qr
    qrc.update! question_row_column_type: qrc_type,
                name: ""

    return qrc.question_row_column_fields.first
  end
end
