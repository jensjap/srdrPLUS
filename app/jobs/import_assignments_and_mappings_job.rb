require 'rubyXL'
require 'rubyXL/convenience_methods'
#require 'date'
#require "import_jobs/pubmed_citation_importer"

class ImportAssignmentsAndMappingsJob < ApplicationJob
  include ImportJobs::PubmedCitationImporter

  queue_as :default

  @@LEADER_ROLE      = Role.find_by(name: Role::LEADER)
  @@CONTRIBUTOR_ROLE = Role.find_by(name: Role::CONTRIBUTOR)
  @@TYPE1_TYPE       = {
    'Categorical' => 1,
    'Continuous' => 2
  }

  def perform(*args)
    @dict_header_index_lookup = {}
    @dict_errors = {
      ws_errors: []
    }
    # Dictionary for quick access to worksheets.
    @wb_worksheets = {
      aam: [],
      wcr: [],
      unknowns: []
    }
    # Dictionary to access to worksheet data.
    @wb_data = {
      wcr: {},
      aam: {}
    }
    @imported_file = ImportedFile.find(args.first)
    @project       = Project.find(@imported_file.project.id)

    buffer = @imported_file.content.download
    _parse_workbook(buffer)
    _sort_out_worksheets     unless @dict_errors[:parse_error_found]
    _process_worksheets_data unless @dict_errors[:wb_errors_found]
    _insert_wb_data_into_db  unless @dict_errors[:ws_errors_found]
  end  # def perform(*args)

  private

  def _parse_workbook(buffer)
    puts "Parsing Workbook.."
    @wb = RubyXL::Parser.parse_buffer(buffer)
    @dict_errors[:parse_error_found] = false
  rescue RuntimeError => e
    puts "  @dict_errors[:parse_error_found] = true"
    @dict_errors[:parse_error_found] = true
  end  # def _parse_workbook(buffer)

  # Build a dictionary with all worksheets.
  #   Three keys
  #   :aam "Assignments and Mappings"
  #   :wcr "Workbook Citation References"
  #   :unknowns
  #
  # @wb_worksheets
  def _sort_out_worksheets
    puts "Sorting out worksheets.."
    @dict_errors[:wb_errors]       = []
    @dict_errors[:wb_errors_found] = false

    # Iterate over worksheets and push into appropriate lists under
    #   their respective keys.
    @wb.worksheets.each do |ws|
      case ws.sheet_name
      when /Assignments? and Mappings?/i
        puts "  Found Assignments and Mappings"
        @wb_worksheets[:aam] << ws

      when /Workbooks? Citations? References?/i
        puts "  Found Workbook Citation References"
        @wb_worksheets[:wcr] << ws

      else
        puts "  Found Unknown Worksheet Names.."
        @wb_worksheets[:unknowns] << ws

      end # case ws.sheet_name
    end # @wb.worksheets.each do |ws|

    # Check for problems and record in @dict_errors[:wb_errors] if present, then
    #   toggle @dict_errors[:wb_errors_found] to true
    if @wb_worksheets[:aam].length > 1
      @dict_errors[:wb_errors] << 'Multiple "Assignments and Mappings" worksheets found.'
      @dict_errors[:wb_errors_found] = true

    elsif @wb_worksheets[:aam].length == 0
      @dict_errors[:wb_errors] << 'No "Assignments and Mappings" worksheets found.'
      @dict_errors[:wb_errors_found] = true

    elsif @wb_worksheets[:wcr].length > 1
      @dict_errors[:wb_errors] << 'Multiple "Workbook Citation References" worksheets found.'
      @dict_errors[:wb_errors_found] = true

    elsif @wb_worksheets[:wcr].length == 0
      @dict_errors[:wb_errors] << 'No "Workbook Citation References" worksheets found.'
      @dict_errors[:wb_errors_found] = true

    end # if @wb[:aam].length > 1
  end # def _sort_out_worksheets

  def _process_worksheets_data
    # Since all other sections will reference the 'Workbook Citation References' section,
    # we need to build its dictionary first.
    #
    # We can assume the first in the lsof workbook_citation_references is the only one.
    # If there were multiple @dict_errors[:wb_errors_found] would have been true and
    # we would not have continued.
    _process_workbook_citation_references_section(@wb_worksheets[:wcr].first)
    _process_assignments_and_mappings_section(@wb_worksheets[:aam].first)
  end # def _process_worksheets_data

  # Populate @wb_data under key :wcr.
  def _process_workbook_citation_references_section(ws)
    puts "Processing Workbook Citation References worksheet"
    cnt_of_data_rows = _find_number_of_data_rows(ws.sheet_data.rows)

    header_row = ws.sheet_data.rows[0]
    data_rows  = ws.sheet_data.rows[1..cnt_of_data_rows]

    data_rows.each do |row|
      next if row[0].blank?

      wb_cit_ref_id = row[0]&.value&.to_i
      pmid          = row[1]&.value
      citation_name = row[2]&.value
      authors       = row[3]&.value
      year          = row[4]&.value.to_i

      if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)
        @dict_errors[:ws_errors] << "Row with invalid Workbook Reference ID found. #{row.cells.to_a}"
        @dict_errors[:ws_errors_found] = true
        next
      end # if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)

      # Store data in @wb_data dictionary.
      #   Note the structure. Each Workbook Citation Reference ID has its own dictionary.
      @wb_data[:wcr][row[0]&.value.to_i] = {
        "pmid"          => pmid,
        "citation_name" => citation_name,
        "authors"       => authors,
        "year"          => year,
        "citation_id"   => _find_citation_id_in_db(pmid, citation_name, authors, year) }
    end  # data_rows.each do |row|
  end  # def _process_workbook_citation_references_section(ws)

  # Find the number of rows based on presence of data in specificied column.
  def _find_number_of_data_rows(rows, col=0)
    puts "Finding number of data rows. rows.length is returning: #{ rows.length.to_s }"
    cnt_data_rows = 0

    rows.each do |row|
      if row.cells.length > 0
        if row.cells[col].present?
          cnt_data_rows = cnt_data_rows + 1
        end  # if row.cells[col].present?
      end  # if row.cells.length > 0
    end if rows.present?  # rows.each do |row|

    puts "We found #{ (cnt_data_rows-1).to_s }"

    # Subtract 1 for header row.
    return cnt_data_rows-1
  end  # def _find_number_of_data_rows(rows)

  # Try to find citation in the following order by:
  #   1. pmid
  #   2. citation_name
  #   3. #!!! TODO: search by authors and year combined.
  #
  # return [INTEGER]
  def _find_citation_id_in_db(pmid, citation_name, authors, year)
    # PMID is a string. Do a little clean-up.
    pmid = pmid.to_i.to_s

    # If no sensible PMID is present we try to find by citation_name, authors and year.
    if pmid.eql?("0")
      citations = Citation.where(name: citation_name)
      return citations.first.id if citations.present?

      puts 'Creating citation from citation_name, authors, year'
      citation = _create_citation_from_citation_name__authors__year(citation_name, authors, year)
      return citation.id if citation

    # Try to find citation already in project.
    elsif pmid.present?
      citations = Citation.where(pmid:)
      return citations.first.id if citations.present?

      puts 'Creating citation from PMID'
      import_citations_from_pubmed_array(@project, [pmid])
      return citation = Citation.find_by(pmid:)
    end

    puts "Unable to match Citation record to row: #{ [pmid, citation_name, authors, year] }"
    @dict_errors[:ws_errors] << "Unable to match Citation record to row: #{ [pmid, citation_name, authors, year] }"
    @dict_errors[:ws_errors_found] = true

    return nil
  end  # def _find_citation_id_in_db(pmid, citation_name, authors, year)

  def _create_citation_from_citation_name__authors__year(citation_name, authors, year)
    citation = Citation.create(name: citation_name)
    citation.journal = Journal.find_or_create_by(publication_date: year)
    authors.split(',').each do |author_name|
      citation.authors << Author.find_or_create_by(name: author_name)
    end if authors.present?  # authors.split(',').each do |author_name|
    citation.save

    return citation
  end  # def _create_citation_from_citation_name__authors__year(citation_name, authors, year)

  # Populate @wb_data under key :aam.
  #   The number of sections is variable. Thus the number of key-value pairs is also
  #   variable. Need to be careful about "Outcomes" as it has its own uniqe structure.
  #   All other sections only have Name and Descriptions as identifiers.
  def _process_assignments_and_mappings_section(ws)
    puts "Processing Assignments and Mappings worksheet"
    cnt_of_data_rows = _find_number_of_data_rows(ws.sheet_data.rows, 1)

    header_row = ws.sheet_data.rows[0]
    data_rows  = ws.sheet_data.rows[1..-1]

    _build_header_index_lookup_dict(header_row)

    data_rows.each do |row|
      next if row[1].blank?

      email         = row[0]&.value
      wb_cit_ref_id = row[1]&.value&.to_i

      user = User.find_by(email: email)
      unless user.present? && (@project.leaders.include?(user) || @project.contributors.include?(user))
        user = @project.leaders.first
      end  # unless user.present? && (@project.leaders.include?(user) || @project.contributors.include?(user))

      if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)
        @dict_errors[:ws_errors] << "Row with invalid Workbook Reference ID found. #{row.cells.to_a}"
        @dict_errors[:ws_errors_found] = true
        next
      end  # if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)

      _sort_row_data(user.email, user.id, wb_cit_ref_id, row)
    end # data_rows.each do |row|
  end # def _process_assignments_and_mappings_section(ws)

  def _build_header_index_lookup_dict(header_row)
    # Trust the database first in regards to the sections present.
    @lsof_type1_section_names = @project
                                .extraction_forms_projects_sections
                                .includes(:section)
                                .joins(:extraction_forms_projects_section_type)
                                .where(extraction_forms_projects_section_types:
        { name: 'Type 1' })
      &.map(&:section)
      &.map(&:name)

    match_targets = [
      /User Email/i,
      /Workbook Citation Reference ID/i,
      /Population Name/i,
      /Population Description/i,
      /Timepoint Name/i,
      /Timepoint Unit/i
    ]
    re_match_targets = Regexp.union(match_targets)

    @lsof_type1_section_names.each do |type1_section_name|
      header_row.cells.each do |cell|
        case cell.value
        when /#{type1_section_name.singularize} Name/i
          @dict_header_index_lookup["#{type1_section_name.singularize} Name"] = cell.column
        when /#{type1_section_name.singularize} Description/i
          @dict_header_index_lookup["#{type1_section_name.singularize} Description"] = cell.column
        when /#{type1_section_name.singularize} Specific Measurement/i
          @dict_header_index_lookup["#{type1_section_name.singularize} Specific Measurement"] = cell.column
        when /#{type1_section_name.singularize} Type/i
          @dict_header_index_lookup["#{type1_section_name.singularize} Type"] = cell.column
        when re_match_targets
          @dict_header_index_lookup["#{ cell.value.strip }"] = cell.column
        end # case cell.value
      end # header_row.cells.each do |cell|
    end # @lsof_type1_section_names.each do |type1_section_name|
  end # def _build_header_index_lookup_dict(header_row)

  # All data is sorted into the following structure:
  #   @wb_data => {
  #     [:aam] => {
  #       [user_email] => {
  #         "Workbook Citation Reference ID" => 123,
  #         "Arms" => [["Arm 1 Name", "Arm 1 Desc."], ["Arm 2 Name", "Arm 2 Desc."]...],
  #         "Outcomes" => [["Outcome 1 Name", "Outcome 1 Spec."], ["Outcome 2 Name", "Outcome 2 Spec."]...],
  #         "Populations" => [["Population 1 Name", "Population 1 Desc."], ["Population 2 Name", "Population 2 Desc."]...],
  #         "Timepoints" => [["Timepoint 1 Name", "Timepoint 1 Unit"], ["Timepoint 2 Name", "Timepoint 2 Unit"]...],
  #         ...
  #   }}}
  def _sort_row_data(user_email, _user_id, wb_cit_ref_id, row)
    @lsof_type1_section_names.each do |type1_section_name|
      @wb_data[:aam][user_email] = {} unless @wb_data[:aam].has_key?(user_email)
      @wb_data[:aam][user_email][wb_cit_ref_id] = {} unless @wb_data[:aam][user_email].has_key?(wb_cit_ref_id)
      unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?(:wb_cit_ref_id)
        @wb_data[:aam][user_email][wb_cit_ref_id][:wb_cit_ref_id] =
          wb_cit_ref_id
      end
      unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?(type1_section_name)
        @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name] =
          []
      end

      case type1_section_name
      when "Outcomes"
        @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name] << [
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value,
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Specific Measurement"]]&.value,
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Type"]]&.value
        ] unless row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value.blank? || @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name].include?(
          [
            row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value,
            row[@dict_header_index_lookup["#{ type1_section_name.singularize } Specific Measurement"]]&.value,
            row[@dict_header_index_lookup["#{ type1_section_name.singularize } Type"]]&.value
          ]
        )

        # Population and Timepoint data is only applicable with Outcomes.
        @wb_data[:aam][user_email][wb_cit_ref_id]["Populations"] = [] unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?("Populations")
        @wb_data[:aam][user_email][wb_cit_ref_id]["Timepoints"] = [] unless @wb_data[:aam][user_email][wb_cit_ref_id].has_key?("Timepoints")

        # Push Population data into
        #   @wb_data => {
        #     [:aam] => {
        #       [user_email] => {
        #         "Populations" => [["Population 1 Name", "Population 1 Desc."], ["Population 2 Name", "Population 2 Desc."]...],
        #         "Timepoints" => [["Timepoint 1 Name", "Timepoint 1 Unit"], ["Timepoint 2 Name", "Timepoint 2 Unit"]...],
        #   }}}
        @wb_data[:aam][user_email][wb_cit_ref_id]["Populations"] << [
          row[@dict_header_index_lookup["Population Name"]]&.value,
          row[@dict_header_index_lookup["Population Description"]]&.value
        ] unless row[@dict_header_index_lookup["Population Name"]]&.value.blank? || @wb_data[:aam][user_email][wb_cit_ref_id]["Populations"].include?(
          [
            row[@dict_header_index_lookup["Population Name"]]&.value,
            row[@dict_header_index_lookup["Population Description"]]&.value
          ]
        )

        @wb_data[:aam][user_email][wb_cit_ref_id]["Timepoints"] << [
          row[@dict_header_index_lookup["Timepoint Name"]]&.value,
          row[@dict_header_index_lookup["Timepoint Unit"]]&.value
        ] unless row[@dict_header_index_lookup["Timepoint Name"]]&.value.blank? || @wb_data[:aam][user_email][wb_cit_ref_id]["Timepoints"].include?(
          [
            row[@dict_header_index_lookup["Timepoint Name"]]&.value,
            row[@dict_header_index_lookup["Timepoint Unit"]]&.value
          ]
        )

      else
        @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name] << [
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value,
          row[@dict_header_index_lookup["#{ type1_section_name.singularize } Description"]]&.value
        ] unless row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value.blank? || @wb_data[:aam][user_email][wb_cit_ref_id][type1_section_name].include?(
          [
            row[@dict_header_index_lookup["#{ type1_section_name.singularize } Name"]]&.value,
            row[@dict_header_index_lookup["#{ type1_section_name.singularize } Description"]]&.value
          ]
        )

      end
    end # @lsof_type1_section_names.each do |type1_section_name|
  end # def _sort_row_data(user_email, user_id, wb_cit_ref_id, row)

  def _insert_wb_data_into_db
    puts "Inserting data into db.."
    @wb_data[:aam].each do |user_email, dict_wb_citation_reference_ids|
      dict_wb_citation_reference_ids.each do |_wb_cit_ref_id, dict_type1_data|
        _process_assignments_and_mappings_extraction_data(user_email, dict_type1_data)
      end # dict_wb_citation_reference_ids.each do |wb_cit_ref_id, dict_type1_data|
    end # @wb_data[:aam].each do |user_email, dict_wb_citation_reference_ids|
  end # def _insert_wb_data_into_db

  def _process_assignments_and_mappings_extraction_data(user_email, data)
    user = User.find_by(email: user_email)

    begin
      citation = Citation.find_by(id: @wb_data[:wcr][data[:wb_cit_ref_id]]["citation_id"])
    rescue => e
      puts e
      return
    end

    extraction = _retrieve_extraction_record(user, citation)
    _toggle_true_all_kqs_for_extraction(extraction) if extraction.present?

    @lsof_type1_section_names.each do |type1_section_name|
      case type1_section_name
      when "Outcomes"
        _insert_outcome_type1_data(extraction, type1_section_name, data)

      else
        _insert_generic_type1_data(extraction, type1_section_name, data)

      end # case type1_section_name
    end # @lsof_type1_section_names.each do |type1_section_name|
  end # def _process_assignments_and_mappings_extraction_data(user_email, data)

  # Params:

  def _insert_outcome_type1_data(extraction, type1_section_name, data)
    data[type1_section_name].each do |lsof_type1_info|
      # Reminder:
      #   lsof_type1_info = [
      #     ["Type 1 Name", "Type 1 Description"],
      #     ["Type 2 Name", "Type 2 Description"],
      #     ...]
      #!!! No good...re-write this.
      _add_outcome_type1_to_extraction(
        extraction,
        type1_section_name,
        lsof_type1_info[0],
        lsof_type1_info[1],
        @@TYPE1_TYPE[lsof_type1_info[2]],
        data["Populations"],
        data["Timepoints"]) unless lsof_type1_info[0].blank?
    end  # data[type1_section_name].each do |lsof_type1_info|
  end  # def _insert_outcome_type1_data(extraction, type1_section_name, data)

  def _insert_generic_type1_data(extraction, type1_section_name, data)
    data[type1_section_name].each do |lsof_type1_info|
      # Reminder:
      #   lsof_type1_info = [
      #     ["Type 1 Name", "Type 1 Description"],
      #     ["Type 2 Name", "Type 2 Description"],
      #     ...]
      next if lsof_type1_info[0].blank?

      _add_generic_type1_to_extraction(
        extraction,
        type1_section_name,
        lsof_type1_info[0],
        lsof_type1_info[1]) unless lsof_type1_info[0].blank?
    end  # data[type1_section_name].each do |lsof_type1_info|
  end  # def _insert_generic_type1_data(extraction, type1_section_name, data)

  def _retrieve_extraction_record(user, citation)
    # CitationsProject may or not exist. Call find_or_create_by.
    citations_project = CitationsProject.find_or_create_by(
      citation:,
      project: @project
    )

    # Find ProjectsUser with Contributor permissions.
    pu = ProjectsUser.find_or_create_by(
      project: @project,
      user:
    )

    pu.make_contributor!

    # Find or create Extraction.
    Extraction.find_or_create_by(
      project: @project,
      citations_project:,
      user: pu.user,
      consolidated: false
    )
  end # def _retrieve_extraction_record(user, citation)

  def _toggle_true_all_kqs_for_extraction(extraction)
    @project.key_questions_projects.each do |kqp|
      ExtractionsKeyQuestionsProjectsSelection.find_or_create_by(
        extraction:,
        key_questions_project: kqp
      )
    end # @project.key_quesetions_projects.each do |kqp|
  end # def _toggle_true_all_kqs_for_extraction(extraction)

  # Find appropriate EEFPS and add type1.
  #
  # This is the params hash sent to eefps controller:
  #   Parameters: {
  #   "utf8"=>"✓",
  #   "authenticity_token"=>"Cgzup9N3RkJV1Zn9Q2GfPb+BdT195g4Rri0io4hL/gEFN6ZxZC5m3+fDW3MPKlGarj6rDZg4pFDPXWMKkC6sXA==",
  #   "extractions_extraction_forms_projects_section"=>{
  #     "action"=>"work",
  #     "extractions_extraction_forms_projects_sections_type1s_attributes"=>{
  #       "0"=>{
  #         "type1_attributes"=>{
  #           "name"=>"testing",
  #           "description"=>"123"
  #         }
  #       }
  #     }
  #   },
  #   "id"=>"299951"}
  def _add_generic_type1_to_extraction(extraction, type1_section_name, type1_name, type1_description)
    efps = @project
           .extraction_forms_projects_sections
           .joins(:section)
           .where(sections: { name: type1_section_name })
           .first
    eefps = ExtractionsExtractionFormsProjectsSection
            .find_by(extraction:, extraction_forms_projects_section: efps)
    n_hash = {
      'extractions_extraction_forms_projects_sections_type1s_attributes' => {
        '0' => {
          'type1_attributes' => {
            'name' => type1_name,
            'description' => type1_description
          }
        }
      }
    }

    eefps.update(n_hash) if eefps.present? && !type1_section_name.eql?('Outcomes')
  end # def _add_generic_type1_to_extraction(extraction, type1_section_name, type1_name, type1_description)

  def _add_outcome_type1_to_extraction(
    extraction,
    type1_section_name,
    type1_name,
    type1_description,
    type1_type_id,
    lsof_populations,
    lsof_timepoints
  )

    # Find the appropriate ExtractionFormsProjectsSection.
    efps = @project
      .extraction_forms_projects_sections
      .joins(:section)
      .where(sections: { name: type1_section_name })
      .first
    # Find the appropriate ExtractionsExtractionFormsProjectsSection.
    eefps = ExtractionsExtractionFormsProjectsSection
      .find_by(extraction: extraction, extraction_forms_projects_section: efps)

    # Do not create new Type1 or ExtractionsExtractionFormsProjectsSectionsType1 unless needed.
    t1 = Type1
      .find_or_create_by(
        name: type1_name.to_s,
        description: type1_description.to_s
      )
    eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1
      .find_or_create_by(
        type1_type_id: type1_type_id,
        extractions_extraction_forms_projects_section: eefps,
        type1: t1
      )
    # Without Ordering on ExtractionsExtractionFormsProjectsSectionsType1 it will not display.
    eefpst1
      .build_ordering(
        position: (
          eefps.extractions_extraction_forms_projects_sections_type1s.length + 1
        )
      ).save

    # Reminder:
    # There is no Ordering on Populations. Populations are saved as ExtractionsExtractionFormsProjectsSectionsType1Row.
    #   lsof_populations = [
    #     ["Population Name 1", "Population 1 Description"],
    #     ["Population Name 2", "Population 2 Description"],
    #     ...]
    # There is no Ordering on Timepoints. Timepoints are saved as ExtractionsExtractionFormsProjectsSectionsType1RowColumn.
    #   lsof_timepoints = [
    #     ["Timepoints Name 1", "Timepoints 1 Unit"],
    #     ["Timepoints Name 2", "Timepoints 2 Unit"],
    #     ...]
    lsof_populations.each do |population_info|
      eefpst1r = ExtractionsExtractionFormsProjectsSectionsType1Row
        .find_or_create_by(
          extractions_extraction_forms_projects_sections_type1: eefpst1,
          population_name: PopulationName.find_or_create_by(
            name: population_info[0].to_s,
            description: population_info[1].to_s
          )
        )

      lsof_timepoints.each do |timepoint_info|
        eefpst1rc = ExtractionsExtractionFormsProjectsSectionsType1RowColumn
          .find_or_create_by(
            extractions_extraction_forms_projects_sections_type1_row: eefpst1r,
            timepoint_name: TimepointName.find_or_create_by(
              name: timepoint_info[0].to_s,
              unit: timepoint_info[1].to_s
            )
          )
      end  # lsof_timepoints.each do |timepoint_info|
    end  # lsof_populations.each do |population_info|
  end  # def _add_outcome_type1_to_extraction(extraction, type1_section_name, type1_name, type1_description, type1_type_id, lsof_populations, lsof_timepoints)
end  # class ImportAssignmentsAndMappingsJob < ApplicationJob
