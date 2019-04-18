class DistillerImporter
  def initialize(project_json, user)
    @id_counter = 1
    @ef_id = new_id
    @project_json = project_json
    # clear extraction and extraction_forms
    @project_json["project"]["extraction_forms"] = { @ef_id => { "sections" => { } } }
    @project_json["project"]["extractions"] = {}
    @qrcf_id_map = {}
    @section_id_map = {}
  end

  def new_id
    @id_counter += 1
  end

  def add_t2_section(imported_file)
    # TODO: Check filetype and importtype and return if wrong
    # TODO: KEY QUESTION STUFF DOES NOT WORK

    kq_hash = { new_id => { name: "FAKE KEY QUESTION" }}

    csv_content = CSV.parse(imported_file.content.gsub /\r/, '')

    efps_hash = create_efps_hash csv_content.first, kq_hash
    @project_json["project"]["extraction_forms"][@ef_id]["sections"][imported_file.section.id] = efps_hash

    csv_content[1..csv_content.length].each do |row|
      extraction_hash = create_extraction_hash(row)
      @project_json["project"]["extractions"][new_id] = { "sections" => {} }
      @project_json["project"]["extractions"][new_id]["sections"][imported_file.section.id] = extraction_hash
    end
  end

  def create_efps_hash(headers, kq_hash)
    shash = {}

    shash['extraction_forms_projects_section_type'] = { id: 2, name: "Type 2" }
    shash['extraction_forms_projects_section_option'] = { id: new_id, by_type1: nil, include_total: nil  }
    shash['questions'] = {}

    headers.each_with_index do |h,i|
      if [0,1,2].include? i
        next
      end
      # ordering is the same as the order in the header
      qhash = {key_questions: kq_hash, name: h, description: "", position: i-2 }
      qrcf_id = new_id
      qhash['question_rows'] = {new_id => {"name":"","question_row_columns":{new_id => {"name":"","question_row_column_type":{"id":1,"name":"text"},"question_row_columns_question_row_column_options":{new_id => {"name":"","question_row_column_option":{"id":1,"name":"answer_choice"}},new_id => {"name":"0","question_row_column_option":{"id":2,"name":"min_length"}},new_id => {"name":"255","question_row_column_option":{"id":3,"name":"max_length"}},new_id => {"name":"0","question_row_column_option":{"id":4,"name":"additional_char"}},new_id => {"name":"0","question_row_column_option":{"id":5,"name":"min_value"}},new_id => {"name":"255","question_row_column_option":{"id":6,"name":"max_value"}},new_id => {"name":"5","question_row_column_option":{"id":7,"name":"coefficient"}},new_id => {"name":"0","question_row_column_option":{"id":8,"name":"exponent"}}},"question_row_column_fields":{qrcf_id => {"name":nil}}}}}}
      shash['questions'][new_id] = qhash
      @qrcf_id_map[i] = qrcf_id
    end

    # --------- User info as another question ---------
    qhash = {key_questions: { new_id => { name: "Imported User Info" } }, name: "Extractor Username", description: "", position: headers.length-2 }
    qrcf_id = new_id
    qhash['question_rows'] = {new_id => {"name":"","question_row_columns":{new_id => {"name":"","question_row_column_type":{"id":1,"name":"text"},"question_row_columns_question_row_column_options":{new_id => {"name":"","question_row_column_option":{"id":1,"name":"answer_choice"}},new_id => {"name":"0","question_row_column_option":{"id":2,"name":"min_length"}},new_id => {"name":"255","question_row_column_option":{"id":3,"name":"max_length"}},new_id => {"name":"0","question_row_column_option":{"id":4,"name":"additional_char"}},new_id => {"name":"0","question_row_column_option":{"id":5,"name":"min_value"}},new_id => {"name":"255","question_row_column_option":{"id":6,"name":"max_value"}},new_id => {"name":"5","question_row_column_option":{"id":7,"name":"coefficient"}},new_id => {"name":"0","question_row_column_option":{"id":8,"name":"exponent"}}},"question_row_column_fields":{qrcf_id => {"name":nil}}}}}}
    shash['questions'][new_id] = qhash
    @qrcf_id_map[1] = qrcf_id
    # --------- User info as another question ---------

    return shash
  end

  def create_extraction_hash(row)
    c_arr = Citation.where( refman: row[0] )
    cp_id = CitationsProject.where( citation: c_arr ).limit(1).first.id

    #assuming user is always one of the project leaders
    ehash = { citation_id: cp_id, extractor_user_id: @user.id, extractor_role_id: Role.find_by(name: 'Leader'), records: {} }

    row.each_with_index do |cell, i|
      if [0,2].include? i
        next
      end
      qrcf_id = @qrcf_id_map[i]

      ehash["records"][new_id] = { question_row_column_field_id: qrcf_id, extractions_extraction_forms_projects_sections_type1_id: nil, name: cell }
    end
    return ehash
  end
end


