require 'rubyXL'
require 'rubyXL/convenience_methods'

class ImportAssignmentsAndMappingsJob < ApplicationJob
  queue_as :default

  @@LEADER_ROLE      = Role.find_by(name: Role::LEADER)
  @@CONTRIBUTOR_ROLE = Role.find_by(name: Role::CONTRIBUTOR)

  def perform(*args)
    @dict_errors   = {}
    @wb_worksheets = {}
    @imported_file = ImportedFile.find(args.first)
    @project       = Project.find(@imported_file.project.id)

    buffer = @imported_file.content.download
    _parse_workbook(buffer)
    _sort_out_worksheets
    _process_worksheets if @dict_errors[:wb_errors].blank?
  end  # def perform(*args)

  private

  def _parse_workbook(buffer)
    begin
      @wb = RubyXL::Parser.parse_buffer(buffer)
      @dict_errors[:parse_error] = nil
    rescue RuntimeError => e
      @dict_errors[:parse_error] = e
    end
  end  # def _parse_workbook(args)

  # Build a dictionary with all worksheets.
  # Two keys are unique: [:outcomes, :workbook_citation_references].
  # The rest of the key-value pairs refer to generic type 1 sections,
  # including 'Arms' section. Generic type 1 section just map
  # User emails with citations, type 1 name and type 1 description.
  #
  # @wb_worksheets
  def _sort_out_worksheets
    # Iterate over worksheets.
    @wb.worksheets.each do |ws|
      case ws.sheet_name
      when "Outcomes"
        @wb_worksheets[:outcomes].present? \
          ? @wb_worksheets[:outcomes] << ws \
          : @wb_worksheets[:outcomes] = [ws]

      when "Workbook Citation References"
        @wb_worksheets[:workbook_citation_references].present? \
          ? @wb_worksheets[:workbook_citation_references] << ws \
          : @wb_worksheets[:workbook_citation_references] = [ws]

      else
        @wb_worksheets[ws.sheet_name].present? \
          ? @wb_worksheets[ws.sheet_name] << ws \
          : @wb_worksheets[ws.sheet_name] = [ws]

      end  # case ws.sheet_name
    end  # @wb.worksheets.each do |ws|

    # Check for problems. For example multiple worksheets with the same name.
    @wb_worksheets.each do |ws_name, lsof_ws|
      if lsof_ws.length > 1
        @dict_errors[:wb_errors].present? \
          ? nil \
          : @dict_errors[:wb_errors] = ["Workbook contains worksheets with duplicate names"]
        @dict_errors[:wb_errors_details].present? \
          ? @dict_errors[:wb_errors_details] << "Workbook contains worksheet \"#{ ws_name }\" multiple times." \
          : @dict_errors[:wb_errors_details] = ["Workbook contains worksheet \"#{ ws_name }\" multiple times."]
      end  # if lsof_ws.length > 1
    end  # @wb_worksheets.each do |ws_name, lsof_ws|
  end  # def _sort_out_worksheets

  def _process_worksheets
    # Since all other sections will reference the 'Workbook Citation References' section,
    # we need to build its dictionary first.
    #
    # We can assume the first in the lsof workbook_citation_references is the only one.
    # If there were multiple @dict_errors[:wb_errors] would not have been blank and
    # we would not have continued.
    _process_workbook_citation_references_section(@wb_worksheets[:workbook_citation_references].first)

    # Now process the rest...note that we skip :workbook_citation_references.
    @wb_worksheets.except(:workbook_citation_references).each do |ws_name, ws|
      _process_type1_sections(ws_name, ws.first)
    end  # @wb_worksheets.except(:workbook_citation_references).each do |ws_name, ws|
  end  # def _process_worksheets

  # Builds a dictionary using Workbook Citation Reference ID as key for faster Citation lookup.
  #
  # @dict_citation_references
  def _process_workbook_citation_references_section(ws)
    @dict_citation_references = {}
    header_row = ws.sheet_data.rows[0]
    data_rows  = ws.sheet_data.rows[1..-1]
    data_rows.each do |row|
      wb_citation_reference_id = row[0].value.to_i
      if @dict_citation_references.has_key?(wb_citation_reference_id)
        @dict_errors[:ws_errors].present? \
          ? @dict_errors[:ws_errors] << "Duplicate Workbook Citation Reference Key detected. Key value: #{ wb_citation_reference_id }" \
          : @dict_errors[:ws_errors] = ["Duplicate Workbook Citation Reference Key detected. Key value: #{ wb_citation_reference_id }"]
      else
        pmid          = row[1]&.value
        citation_name = row[2]&.value
        refman        = row[3]&.value
        authors       = row[4]&.value
        @dict_citation_references[wb_citation_reference_id] = {
          "pmid"          => pmid,
          "citation_name" => citation_name,
          "refman"        => refman,
          "authors"       => authors,
          "citation_id"   => _find_citation_id_in_db(row)
        }
      end  # if @dict_citation_references.has_key?(row[0].value.to_i)
    end  # data_rows.each do |row|
  end  # def _process_workbook_citation_references_section

  def _find_citation_id_in_db(row)
    pmid          = row[1]&.value
    citation_name = row[2]&.value
    refman        = row[3]&.value
    authors       = row[4]&.value

    if pmid.present?
      return Citation.find_by(pmid: pmid)&.id
    end  # if pmid.present?

    if citation_name.present?
      return Citation.find_by(name: citation_name)&.id
    end  # if citation_name.present?

    @dict_errors[:ws_errors].present? \
      ? @dict_errors[:ws_errors] << "Unable to match Citation record to row: #{ row.cells.map(&:value) }" \
      : @dict_errors[:ws_errors] = ["Unable to match Citation record to row: #{ row.cells.map(&:value) }"]

    return nil
  end  # def _find_citation_in_db(row)

  def _process_type1_sections(ws_name, ws)
    sheet_data = ws.sheet_data
    sheet_data.rows[1..-1].each do |row|
      user_email        = row[0]&.value
      lsof_citation_ids = row[1]&.value.to_s.split(',').map(&:to_i)
      type1_name        = row[2]&.value
      type1_description = row[3]&.value

      # Additional processing for "Outcomes" section.
      if ws_name.eql?(:outcomes)
        outcome_type           = row[4]&.value
        population_name        = row[5]&.value
        population_description = row[6]&.value
        timepoint_name         = row[7]&.value
        timepoint_unit         = row[8]&.value
        successful, e = _process_row(
          ws_name,
          user_email,
          lsof_citation_ids,
          type1_name,
          type1_description,
          outcome_type,
          population_name,
          population_description,
          timepoint_name,
          timepoint_unit
        )

      else
        successful, e = _process_row(
          ws_name,
          user_email,
          lsof_citation_ids,
          type1_name,
          type1_description
        )
      end  # if ws_name.eql?(:outcomes)

      unless successful
        @dict_errors[:row_processing_errors].present? \
          ? @dict_errors[:row_processing_errors] << "Error: \"#{ e }\", row: [#{ user_email }, #{ lsof_citation_ids }], while processing row in worksheet: #{ ws_name }" \
          : @dict_errors[:row_processing_errors] = ["Error: \"#{ e }\", row: [#{ user_email }, #{ lsof_citation_ids }], while processing row in worksheet: #{ ws_name }"]
      end  # if successful
    end  # sheet_data.rows.each do |row|
  end  # def _process_outcomes_section

  def _process_row(ws_name, email, wb_citation_ids, type1_name, type1_description,
    outcome_type=nil, population_name=nil, population_description=nil,
    timepoint_name=nil, timepoint_unit=nil)

    user = User.find_by(email: email)
    return false, "Unable to retrieve user." unless user.present?

    wb_citation_ids.each do |wb_citation_id|
      # Retrieve citation.
      citation = _retrieve_full_citation_record_from_db(wb_citation_id)
      return false, "Unable to retrieve citation for wb citation id #{ wb_citation_id }." unless citation.present?

      # find_or_create extraction.
      extraction = _retrieve_extraction_record(user, citation)
      return false, "Unable to retrieve extraction for wb citation id #{ wb_citation_id }" unless extraction.present?
      # Toggle all KQs for the extraction to true.
      _toggle_true_all_kqs_for_extraction(extraction)

      # find_or_create type 1.
      _add_type1_to_extraction(extraction, ws_name, type1_name, type1_description)
    end  # wb_citation_ids.each do |wb_citation_id|

    return true, nil
  end  # def _process_row(email, wb_citation_ids, type1_name, ..., timepoint_unit=nil)

  def _retrieve_full_citation_record_from_db(wb_citation_id)
    citation = nil
    wb_citation = @dict_citation_references[wb_citation_id]
    begin
      citation = Citation.find(wb_citation["citation_id"])
    rescue ActiveRecord::RecordNotFound=> exception
      citation = Citation.find_by(name: wb_citation["citation_name"])
    ensure
      return citation
    end
  end  # def _retrieve_full_citation_record_from_db(wb_citation_id)

  def _retrieve_extraction_record(user, citation)
      # CitationsProject object should exist, otherwise it would not have been
      # part of the template.
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
  end  # def _retrieve_extraction_record(user_id, citation_id)

  def _toggle_true_all_kqs_for_extraction(extraction)
    @project.key_questions_projects.each do |kqp|
      ExtractionsKeyQuestionsProjectsSelection.find_or_create_by(
        extraction: extraction,
        key_questions_project: kqp
      )
    end  # @project.key_quesetions_projects.each do |kqp|
  end  # def _toggle_true_all_kqs_for_extraction(extraction)

  # Find appropriate EEFPS and add type1.
  def _add_type1_to_extraction(extraction, ws_name, type1_name, type1_description)
    efps = @project.extraction_forms_projects_sections.joins(:section).where(sections: { name: ws_name }).first
    eefps = ExtractionsExtractionFormsProjectsSection.find_by(extraction: extraction, extraction_forms_projects_section: efps)
    n_hash = {"extractions_extraction_forms_projects_sections_type1s_attributes"=>
               {"0"=>
                 {"type1_attributes"=>
                   {"name"=>type1_name, "description"=>type1_description}
                 }
               }
             }

    if eefps.present?
      eefps.update(n_hash) unless ws_name.eql?(:outcomes)
    end


    # potentially add into type1s table
    # how do we add into suggestions table?
    # add into extractions_extraction_forms_projects_sections_type1s table
    # need insert into orderings table

    # this is params sent to eefps controller:
    # Parameters: {
    # "utf8"=>"✓",
    # "authenticity_token"=>"Cgzup9N3RkJV1Zn9Q2GfPb+BdT195g4Rri0io4hL/gEFN6ZxZC5m3+fDW3MPKlGarj6rDZg4pFDPXWMKkC6sXA==",
    # "extractions_extraction_forms_projects_section"=>{
    #   "action"=>"work",
    #   "extractions_extraction_forms_projects_sections_type1s_attributes"=>{"0"=>{"type1_attributes"=>{"name"=>"testing", "description"=>"123"}}}
    # },
    # "id"=>"299951"}

    # Arms efps: @project.extraction_forms_projects_sections.joins(:section).where(sections: { name: "arms" })

  end  # def _add_type1_to_extraction(extraction, ws_name, type1_name, type1_description)

end  # class ImportAssignmentsAndMappingsJob < ApplicationJob
