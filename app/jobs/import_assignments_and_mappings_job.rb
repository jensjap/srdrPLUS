require 'rubyXL'
require 'rubyXL/convenience_methods'
require "import_jobs/_pubmed_citation_importer"

class ImportAssignmentsAndMappingsJob < ApplicationJob
  queue_as :default

  @@LEADER_ROLE      = Role.find_by(name: Role::LEADER)
  @@CONTRIBUTOR_ROLE = Role.find_by(name: Role::CONTRIBUTOR)

  def perform(*args)
    @dict_header_index_lookup = {}
    @dict_errors   = {
      :ws_errors => [] }
    # Dictionary for quick access to worksheets.
    @wb_worksheets = {
      :aam => [],
      :wcr => [],
      :unknowns => [] }
    # Dictionary to access to worksheet data.
    @wb_data = {
      :wcr => {},
      :aam => {} }
    @imported_file = ImportedFile.find(args.first)
    @project       = Project.find(@imported_file.project.id)

    buffer = @imported_file.content.download
    _parse_workbook(buffer)
    _sort_out_worksheets unless @dict_errors[:parse_error_found]
    _process_worksheets_data unless @dict_errors[:wb_errors_found]
    _insert_wb_data_into_db unless @dict_errors[:ws_errors_found]

  end  # def perform(*args)

  private

  def _parse_workbook(buffer)
    begin
      @wb = RubyXL::Parser.parse_buffer(buffer)
      @dict_errors[:parse_error_found] = false
    rescue RuntimeError => e
      @dict_errors[:parse_error_found] = true
    end
  end  # def _parse_workbook(buffer)

  # Build a dictionary with all worksheets.
  #   Three keys
  #   :aam "Assignments and Mappings"
  #   :wcr "Workbook Citation References"
  #   :unknowns
  #
  # @wb_worksheets
  def _sort_out_worksheets
    @dict_errors[:wb_errors]       = []
    @dict_errors[:wb_errors_found] = false

    # Iterate over worksheets and push into appropriate lists under
    #   their respective keys.
    @wb.worksheets.each do |ws|
      case ws.sheet_name
      when /Assignments and Mappings/
        @wb_worksheets[:aam] << ws

      when /Workbook Citation References/
        @wb_worksheets[:wcr] << ws

      else
        @wb_worksheets[:unknowns] << ws

      end  # case ws.sheet_name
    end  # @wb.worksheets.each do |ws|

    # Check for problems and record in @dict_errors[:wb_errors] if present, then
    #   toggle @dict_errors[:wb_errors_found] to true
    if @wb_worksheets[:aam].length > 1
      @dict_errors[:wb_errors] << "Multiple \"Assignments and Mappings\" worksheets found."
      @dict_errors[:wb_errors_found] = true

    elsif @wb_worksheets[:aam].length == 0
      @dict_errors[:wb_errors] << "No \"Assignments and Mappings\" worksheets found."
      @dict_errors[:wb_errors_found] = true

    elsif @wb_worksheets[:wcr].length > 1
      @dict_errors[:wb_errors] << "Multiple \"Workbook Citation References\" worksheets found."
      @dict_errors[:wb_errors_found] = true

    elsif @wb_worksheets[:wcr].length == 0
      @dict_errors[:wb_errors] << "No \"Workbook Citation References\" worksheets found."
      @dict_errors[:wb_errors_found] = true

    end  # if @wb[:aam].length > 1
  end  # def _sort_out_worksheets

  def _process_worksheets_data
    # Since all other sections will reference the 'Workbook Citation References' section,
    # we need to build its dictionary first.
    #
    # We can assume the first in the lsof workbook_citation_references is the only one.
    # If there were multiple @dict_errors[:wb_errors_found] would have been true and
    # we would not have continued.
    _process_workbook_citation_references_section(@wb_worksheets[:wcr].first)
    _process_assignments_and_mappings_section(@wb_worksheets[:aam].first)
  end  # def _process_worksheets_data

  # Populate @wb_data under key :wcr.
  def _process_workbook_citation_references_section(ws)
    header_row = ws.sheet_data.rows[0]
    data_rows  = ws.sheet_data.rows[1..-1]

    data_rows.each do |row|
      wb_cit_ref_id = row[0]&.value&.to_i
      pmid          = row[1]&.value
      citation_name = row[2]&.value
      refman        = row[3]&.value
      authors       = row[4]&.value

      if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)
        @dict_errors[:ws_errors] << "Row with invalid Workbook Reference ID found. #{ row.cells.to_a }"
        @dict_errors[:ws_errors_found] = true
        next
      end  # if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)

      # Store data in @wb_data dictionary.
      #   Note the structure. Each Workbook Citation Reference ID has its own dictionary.
      @wb_data[:wcr][row[0]&.value.to_i] = {
        "pmid"          => pmid,
        "citation_name" => citation_name,
        "refman"        => refman,
        "authors"       => authors,
        "citation_id"   => _find_citation_id_in_db(pmid, citation_name, refman, authors) }
    end  # data_rows.each do |row|
  end  # def _process_workbook_citation_references_section(ws)

  def _find_citation_id_in_db(pmid, citation_name, refman, authors)
    citation = Citation.find_by(pmid: pmid) if pmid.present?
    return citation.id if citation

    import_citations_from_pubmed_array(@project, [pmid]) if pmid.present?
    citation = Citation.find_by(pmid: pmid) if pmid.present?
    return citation.id if citation

    citation = Citation.find_by(name: citation_name) if citation_name.present?
    return citation.id if citation

    @dict_errors[:ws_errors] << "Unable to match Citation record to row: #{ [pmid, citation_name, refman, authors] }"
    @dict_errors[:ws_errors_found] = true

    return nil
  end  # def _find_citation_id_in_db(pmid, citation_name, refman, authors)

  # Populate @wb_data under key :aam.
  #   The number of sections is variable. Thus the number of key-value pairs is also
  #   variable. Need to be careful about "Outcomes" as it has its own uniqe structure.
  #   All other sections only have Name and Descriptions as identifiers.
  def _process_assignments_and_mappings_section(ws)
    header_row = ws.sheet_data.rows[0]
    data_rows  = ws.sheet_data.rows[1..-1]

    _build_header_index_lookup_dict(header_row)

    data_rows.each do |row|
      email         = row[0]&.value
      wb_cit_ref_id = row[1]&.value&.to_i


      user = User.find_by(email: email)
      if user.blank? || !@project.leaders.include?(user) || !@project.contributors.include?(user)
        user = @project.leaders.first
      end  # if user.blank? || ~@project.leaders.include?(user) || ~@project.contributors.include?(user)

      if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)
        @dict_errors[:ws_errors] << "Row with invalid Workbook Reference ID found. #{ row.cells.to_a }"
        @dict_errors[:ws_errors_found] = true
        next
      end  # if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)

      _sort_row_data(user.email, user.id, wb_cit_ref_id, row)

    end  # data_rows.each do |row|
  end  # def _process_assignments_and_mappings_section(ws)

  def _build_header_index_lookup_dict(header_row)
    # Trust the database first in regards to the sections present.
    @lsof_type1_section_names = @project
      .extraction_forms_projects_sections
      .includes(:section)
      .joins(:extraction_forms_projects_section_type)
      .where(extraction_forms_projects_section_types:
        { name: "Type 1" })
      &.map(&:section)
      &.map(&:name)

    match_targets = [
      /User Email/i,
      /Workbook Citation Reference ID/i,
      /Population Name/i,
      /Population Description/i,
      /Timepoint Name/i,
      /Timepoint Unit/i ]
    re_match_targets = Regexp.union(match_targets)

    @lsof_type1_section_names.each do |type1_section_name|
      header_row.cells.each do |cell|
        case cell.value
        when /#{ type1_section_name.singularize } Name/
          @dict_header_index_lookup["#{ type1_section_name.singularize } Name"] = cell.column
        when /#{ type1_section_name.singularize } Description/
          @dict_header_index_lookup["#{ type1_section_name.singularize } Description"] = cell.column
        when /#{ type1_section_name.singularize } Specific Measurement/
          @dict_header_index_lookup["#{ type1_section_name.singularize } Specific Measurement"] = cell.column
        when /#{ type1_section_name.singularize } Type/
          @dict_header_index_lookup["#{ type1_section_name.singularize } Type"] = cell.column
        when re_match_targets
          @dict_header_index_lookup["#{ cell.value }"] = cell.column
        end  # case cell.value
      end  # header_row.cells.each do |cell|
    end  # @lsof_type1_section_names.each do |type1_section_name|
  end  # def _build_header_index_lookup_dict(header_row)

  # All data is sorted into the following structure:
  #   @wb_data => {
  #     [:aam] => {
  #       [user_email] => {
  #         "Workbook Citation Reference ID" => 123,
  #         "Arms" => [["Arm 1 Name", "Arm 1 Desc."], ["Arm 2 Name", "Arm 2 Desc."]...],
  #         "Outcomes" => [["Outcome 1 Name", "Outcome 1 Spec."], ["Outcome 2 Name", "Outcome 2 Spec."]...],
  #         "Populations" => [["Timepoint 1 Name", "Timepoint 1 Desc."], ["Timepoint 2 Name", "Timepoint 2 Desc."]...],
  #         ...
  #   }}}
  def _sort_row_data(user_email, user_id, wb_cit_ref_id, row)
    @lsof_type1_section_names.each do |type1_section_name|
      @wb_data[:aam][user_email] = {} unless @wb_data[:aam].has_key?(user_email)
      @wb_data[:aam][user_email][wb_cit_ref_id] = {} unless @wb_data[:aam][user_email].has_key?(wb_cit_ref_id)
      @wb_data[:aam][user_email][wb_cit_ref_id][:wb_cit_ref_id] = wb_cit_ref_id unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?(:wb_cit_ref_id)
      @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name] = [] unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?(type1_section_name)

      case type1_section_name
      when "Outcomes"
        @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name] << [
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value,
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Specific Measurement"]]&.value,
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Type"]]&.value
        ] unless row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value.blank?

        # Population and Timepoint data is only applicable with Outcomes.
        @wb_data[:aam][user_email][wb_cit_ref_id]["Populations"] = [] unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?("Populations")
        @wb_data[:aam][user_email][wb_cit_ref_id]["Timepoints"] = [] unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?("Timepoints")
        @wb_data[:aam][user_email][wb_cit_ref_id]["Populations"] << [
          row[@dict_header_index_lookup["Population Name"]]&.value,
          row[@dict_header_index_lookup["Population Description"]]&.value
        ] unless row[@dict_header_index_lookup["Population Name"]]&.value.blank?
        @wb_data[:aam][user_email][wb_cit_ref_id]["Timepoints"] << [
          row[@dict_header_index_lookup["Timepoint Name"]]&.value,
          row[@dict_header_index_lookup["Timepoint Unit"]]&.value
        ] unless row[@dict_header_index_lookup["Timepoint Name"]]&.value.blank?

      else
        @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name] << [
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value,
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Description"]]&.value
        ] unless row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value.blank?

      end
    end  # @lsof_type1_section_names.each do |type1_section_name|
  end  # def _sort_row_data(user_email, user_id, wb_cit_ref_id, row)

  def _insert_wb_data_into_db
    @wb_data[:aam].each do |user_email, dict_wb_citation_reference_ids|
      dict_wb_citation_reference_ids.each do |wb_cit_ref_id, dict_type1_data|
        _process_assignments_and_mappings_extraction_data(user_email, dict_type1_data)
      end  # dict_wb_citation_reference_ids.each do |wb_cit_ref_id, dict_type1_data|
    end  # @wb_data[:aam].each do |user_email, dict_wb_citation_reference_ids|
  end  # def _insert_wb_data_into_db

  def _process_assignments_and_mappings_extraction_data(user_email, data)
    user     = User.find_by(email: user_email)
    citation = Citation.find_by(id: @wb_data[:wcr][data[:wb_cit_ref_id]]["citation_id"])
    @lsof_type1_section_names.each do |type1_section_name|
      case type1_section_name
      when "Outcomes"
        _insert_outcome_type1_data(user, citation, type1_section_name, data)

      else
        _insert_generic_type1_data(user, citation, type1_section_name, data)

      end  # case type1_section_name
    end  # @lsof_type1_section_names.each do |type1_section_name|
  end  # def _process_assignments_and_mappings_extraction_data(user_email, data)

  def _insert_outcome_type1_data(user, citation, type1_section_name, data)
  end  # def _insert_outcome_type1_data(user, citation, type1_section_name, data)

  def _insert_generic_type1_data(user, citation, type1_section_name, data)
    extraction = _retrieve_extraction_record(user, citation)
    _toggle_true_all_kqs_for_extraction(extraction) if extraction.present?
    data[type1_section_name].each do |lsof_type1_info|
      # Reminder:
      #   lsof_type1_info = [
      #     ["Type 1 Name", "Type 1 Description"],
      #     ["Type 2 Name", "Type 2 Description"],
      #     ...]
      _add_generic_type1_to_extraction(
        extraction,
        type1_section_name,
        lsof_type1_info[0],
        lsof_type1_info[1]) unless lsof_type1_info[0].blank?
    end  # data[type1_section_name].each do |lsof_type1_info|
  end  # def _insert_generic_type1_data(user, citation, type1_section_name, data)

  def _retrieve_extraction_record(user, citation)
      # CitationsProject may or not exist. Call find_or_create_by.
      citations_project = CitationsProject.find_or_create_by(
        citation: citation,
        project: @project
      )

      # Find ProjectsUsersRole with Contributor role.
      pu  = ProjectsUser.find_or_create_by(
        project: @project,
        user: user
      )

      # If this user is not a Contributor then make him one.
      pur = ProjectsUsersRole.find_by(
        projects_user: pu,
        role: @@LEADER_ROLE
      )
      unless pur.present?
        pur = ProjectsUsersRole.find_or_create_by(
          projects_user: pu,
          role: @@CONTRIBUTOR_ROLE
        )
      end  # unless pur.present?

      # Find or create Extraction.
      extraction = Extraction.find_or_create_by(
        project: @project,
        citations_project: citations_project,
        projects_users_role: pur,
        consolidated: false
      )

      return extraction
  end  # def _retrieve_extraction_record(user, citation)

  def _toggle_true_all_kqs_for_extraction(extraction)
    @project.key_questions_projects.each do |kqp|
      ExtractionsKeyQuestionsProjectsSelection.find_or_create_by(
        extraction: extraction,
        key_questions_project: kqp
      )
    end  # @project.key_quesetions_projects.each do |kqp|
  end  # def _toggle_true_all_kqs_for_extraction(extraction)

  # Find appropriate EEFPS and add type1.
  def _add_generic_type1_to_extraction(extraction, type1_section_name, type1_name, type1_description)
    efps = @project
      .extraction_forms_projects_sections
      .joins(:section)
      .where(sections: { name: type1_section_name })
      .first
    eefps = ExtractionsExtractionFormsProjectsSection
      .find_by(extraction: extraction, extraction_forms_projects_section: efps)
    n_hash = {"extractions_extraction_forms_projects_sections_type1s_attributes"=>
               {"0"=>
                 {"type1_attributes"=>
                   {"name"=>type1_name, "description"=>type1_description}
                 }
               }
             }

    if eefps.present?
      eefps.update(n_hash) unless type1_section_name.eql?("Outcomes")
    end

    # potentially add into type1s table
    # how do we add into suggestions table?
    # add into extractions_extraction_forms_projects_sections_type1s table
    # need insert into orderings table

    # This is the params hash sent to eefps controller:
    # Parameters: {
    # "utf8"=>"✓",
    # "authenticity_token"=>"Cgzup9N3RkJV1Zn9Q2GfPb+BdT195g4Rri0io4hL/gEFN6ZxZC5m3+fDW3MPKlGarj6rDZg4pFDPXWMKkC6sXA==",
    # "extractions_extraction_forms_projects_section"=>{
    #   "action"=>"work",
    #   "extractions_extraction_forms_projects_sections_type1s_attributes"=>{"0"=>{"type1_attributes"=>{"name"=>"testing", "description"=>"123"}}}
    # },
    # "id"=>"299951"}

    # Arms efps: @project.extraction_forms_projects_sections.joins(:section).where(sections: { name: "arms" })

  end  # def _add_generic_type1_to_extraction(extraction, type1_section_name, type1_name, type1_description)
end  # class ImportAssignmentsAndMappingsJob < ApplicationJob
