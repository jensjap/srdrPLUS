require 'rubyXL'
require 'rubyXL/convenience_methods'

class ImportAssignmentsAndMappingsJob < ApplicationJob
  include ImportJobs::PubmedCitationImporter
  include ImportHelpers::ImportAssignmentsAndMappingsJobHelpers

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

    buffer = get_buffer_from_imported_file(@imported_file)

    _parse_workbook(buffer)
    _sort_out_worksheets     unless @dict_errors[:parse_error_found]
    _process_worksheets_data unless @dict_errors[:wb_errors_found]
    _insert_wb_data_into_db  unless @dict_errors[:ws_errors_found]
  end

  private

  def _parse_workbook(buffer)
    puts "Parsing Workbook.."
    @wb = RubyXL::Parser.parse_buffer(buffer)
    @dict_errors[:parse_error_found] = false
  rescue RuntimeError => e
    puts "  @dict_errors[:parse_error_found] = true"
    @dict_errors[:parse_error_found] = true
  end

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

      end
    end

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

    end
  end

  def _process_worksheets_data
    # Since all other sections will reference the 'Workbook Citation References' section,
    # we need to build its dictionary first.
    #
    # We can assume the first in the lsof workbook_citation_references is the only one.
    # If there were multiple @dict_errors[:wb_errors_found] would have been true and
    # we would not have continued.
    _process_workbook_citation_references_section(@wb_worksheets[:wcr].first)
    _process_assignments_and_mappings_section(@wb_worksheets[:aam].first)
  end

  # Populate @wb_data under key :wcr.
  def _process_workbook_citation_references_section(ws)
    puts "Processing Workbook Citation References worksheet"
    cnt_of_data_rows = _find_number_of_data_rows(ws.sheet_data.rows)

    header_row = ws.sheet_data.rows[0]
    data_rows  = ws.sheet_data.rows[1..cnt_of_data_rows]

    dict_header_index_lookup = _build_header_index_lookup_dict_wbcr(header_row)

    data_rows.each do |row|
      next if row[0].blank?

      wb_cit_ref_id = row[dict_header_index_lookup['Workbook Citation Reference ID']]&.value&.to_i
      pmid          = row[dict_header_index_lookup['PMID']]&.value
      citation_name = row[dict_header_index_lookup['Citation Name']]&.value
      refman        = row[dict_header_index_lookup['RefMan']]&.value&.truncate(200)
      authors       = row[dict_header_index_lookup['Authors']]&.value
      year          = row[dict_header_index_lookup['Publication Year']]&.value

      if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)
        @dict_errors[:ws_errors] << "Row with invalid Workbook Reference ID found. #{row.cells.to_a}"
        @dict_errors[:ws_errors_found] = true
        next
      end # if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)

      # Store data in @wb_data dictionary.
      #   Note the structure. Each Workbook Citation Reference ID has its own dictionary.
      @wb_data[:wcr][row[0]&.value.to_i] = {
        'pmid' => pmid,
        'citation_name' => citation_name,
        'refman' => refman,
        'authors' => authors,
        'year' => year,
        'citation_id' => _find_citation_id_in_db(pmid, citation_name, refman, authors, year)
      }
    end
  end

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
  end

  # Try to find citation in the following order by:
  #   1. pmid
  #   2. citation_name
  #   3. #!!! TODO: search by authors and year combined.
  #
  # return [INTEGER]
  def _find_citation_id_in_db(pmid, name, refman, authors, year)
    # PMID is a string. Do a little clean-up.
    pmid = pmid.to_i.to_s

    citation = nil

    if !pmid.eql?('0')
      # Try to find citation already in system.
      citation = Citation.find_by(pmid:)
      return citation.id if citation

      puts 'Unable to locate PMID in system'
      puts 'Attempting to efetch'
      import_citations_from_pubmed_array(@project, [pmid], false)
      citation = Citation.find_by(pmid:)
      return citation.id if citation

      puts 'Unable to efetch'

    else
      puts 'Find citation by name'
      citation = Citation.find_by(name:)
      return citation.id if citation

      puts 'Unable to find citation by name'

    end

    puts 'Creating citation from citation_name, authors, year'
    citation = _create_citation_from_citation_name__authors__year(name, refman, authors, year)
    citation.id
  end

  def _create_citation_from_citation_name__authors__year(name, refman, authors, year)
    citation = Citation.create!(name:)
    citation.journal = Journal.find_or_create_by!(publication_date: year)
    citation.authors = authors if authors.present?
    citation.refman = refman

#    if authors&.match(/\[(.*?)\]/)
#      authors.scan(/\[(.*?)\]/).each do |author|
#        citation.authors << Author.find_or_create_by!(name: author)
#      end
#    else
#      authors&.split(';').each do |author|
#        citation.authors << Author.find_or_create_by!(name: author)
#      end
#    end

    citation.save!
    citation
  end

  # Populate @wb_data under key :aam.
  #   The number of sections is variable. Thus the number of key-value pairs is also
  #   variable. Need to be careful about "Outcomes" as it has its own uniqe structure.
  #   All other sections only have Name and Descriptions as identifiers.
  def _process_assignments_and_mappings_section(ws)
    puts "Processing Assignments and Mappings worksheet"
    cnt_of_data_rows = _find_number_of_data_rows(ws.sheet_data.rows, 1)

    header_row = ws.sheet_data.rows[0]
    data_rows  = ws.sheet_data.rows[1..-1]

    _build_header_index_lookup_dict_aam(header_row)

    data_rows.each do |row|
      next if row[1].blank?

      email          = row[0]&.value
      wb_cit_ref_ids = row[1]&.value&.to_s&.split(',')&.map(&:to_i)
      wb_cit_ref_id  = wb_cit_ref_ids.first

      user = User.find_by(email: email)
      unless user.present? && (@project.leaders.include?(user) || @project.contributors.include?(user))
        user = @project.leaders.first
      end

      if wb_cit_ref_id.blank? || wb_cit_ref_id.eql?(0)
        @dict_errors[:ws_errors] << "Row with invalid Workbook Reference ID found. #{row.cells.to_a}"
        @dict_errors[:ws_errors_found] = true
        next
      end

      wb_cit_ref_ids.each do |wb_cit_ref_id|
        _sort_row_data(user.email, user.id, wb_cit_ref_id, row)
      end
    end
  end

  def _build_header_index_lookup_dict_aam(header_row)
    # Trust the database first in regards to the sections present.
    @lsof_type1_section_names = @project
      .extraction_forms_projects
      .first
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
          @dict_header_index_lookup[cell.value.to_s.strip] = cell.column
        end
      end
    end
  end

  def _build_header_index_lookup_dict_wbcr(header_row)
    dict_header_index_lookup = {}
    match_targets = [
      /Workbook Citation Reference ID/i,
      /PMID/i,
      /Citation Name/i,
      /RefMan/i,
      /Authors/i,
      /Publication Year/i
    ]
    re_match_targets = Regexp.union(match_targets)

    match_targets.each do |target|
      # In order to prevent the lookup from crashing when a key isn't present
      # we ensure all keys exist and set to some high index beyond what maximum
      # number of Excel columns is supported as the value.
      dict_header_index_lookup[target.to_s.match(/\(\?i-mx:(.*?)\??\)/)[1]] = 1_000_000
    end

    # Next we set the correct cell.column for matched headers.
    header_row.cells.each do |cell|
      dict_header_index_lookup[cell.value.to_s.strip] = cell.column if re_match_targets
    end

    dict_header_index_lookup
  end

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
    end
  end

  def _insert_wb_data_into_db
    puts "Inserting data into db.."
    @wb_data[:aam].each do |user_email, dict_wb_citation_reference_ids|
      dict_wb_citation_reference_ids.each do |_wb_cit_ref_id, dict_type1_data|
        _process_assignments_and_mappings_extraction_data(user_email, dict_type1_data)
      end
    end
  end

  def _process_assignments_and_mappings_extraction_data(user_email, data)
    # Check that we have data for data[:wb_cit_ref_id].
    # If we don't that means a reference ID exists in the 'Assignments and Mappings'
    # worksheet for which we have no citation information, i.e. it's missing in the
    # 'Workbook Citation Reference' worksheet.
    return if @wb_data[:wcr][data[:wb_cit_ref_id]].nil?

    # Check that we managed to create a citation.
    citation_id = @wb_data[:wcr][data[:wb_cit_ref_id]]['citation_id']
    return if citation_id.blank?

    user = User.find_by(email: user_email)
    citation = Citation.find(citation_id)

    extraction = _retrieve_extraction_record(user, citation)
    _toggle_true_all_kqs_for_extraction(extraction) if extraction.present?

    @lsof_type1_section_names.each do |type1_section_name|
      case type1_section_name
      when 'Outcomes'
        _insert_outcome_type1_data(extraction, type1_section_name, data)

      else
        _insert_generic_type1_data(extraction, type1_section_name, data)

      end
    end
  end

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
    end
  end

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
    end
  end

  def _retrieve_extraction_record(user, citation)
    # CitationsProject may or not exist. Call find_or_create_by.
    citations_project = CitationsProject.find_or_create_by!(
      citation:,
      project: @project
    )

    # Find ProjectsUser with Contributor permissions.
    pu = ProjectsUser.find_or_create_by!(
      project: @project,
      user:
    )

    pu.make_contributor!

    # Find or create Extraction.
    Extraction.find_or_create_by!(
      project: @project,
      citations_project:,
      user:,
      consolidated: false
    )
  end

  def _toggle_true_all_kqs_for_extraction(extraction)
    @project.key_questions_projects.each do |kqp|
      ExtractionsKeyQuestionsProjectsSelection.find_or_create_by(
        extraction:,
        key_questions_project: kqp
      )
    end
  end

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
      .extraction_forms_projects
      .first
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
  end

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
      .extraction_forms_projects
      .first
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
    eefpst1.pos = eefps
                  .extractions_extraction_forms_projects_sections_type1s
                  .length + 1
    eefpst1.save

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
      end
    end
  end
end
