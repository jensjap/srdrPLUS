class ExportAssignmentsAndMappingsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    project_id = args.first
    @project = Project.find(project_id)

    @ws_assignments_and_mappings     = nil
    @ws_workbook_citation_references = nil
    @lsof_type1_names                = []

    Axlsx::Package.new do |package|
      _create_worksheets(package)
      _populate_assignments_and_mappings_ws(package)
      _fill_workbook_citation_references_section(package)

      return package
    end  # END Axlsx::Package.new do |package|
  end  # END def perform(*args)

  private

  def _create_worksheets(p)
    # Assignments and Mappings Worksheet.
    #   All Type 1 information is collected here. Consider grouping rows by
    #   Workbook Citation Reference ID. Then each column is a unique set of
    #   [Type 1 Name / Type 1 Description],
    #   [Outcome Name / Outcome Specific Measurement / Outcome Type],
    #   [Population Name / Population Description], and
    #   [Timepoint Name / Timepoint Unit]
    @ws_assignments_and_mappings = p.workbook.add_worksheet(
      name: "Assignments and Mappings")

    # Workbook Citation References.
    #   The "Workbook Citation Reference ID" is workbook specific and arbitrary.
    #   there is no relation to any IDs within the application. Internal workbook
    #   use only.
    @ws_workbook_citation_references = p.workbook.add_worksheet(
      name: "Workbook Citation References")
  end  # END def _create_worksheets(p)

  def _populate_assignments_and_mappings_ws(p)
    _create_header_row
    _fill_existing_assignments_and_mappings_ws
  end  # def _populate_assignments_and_mappings_ws(p)

  def _create_header_row
    column_header_elements = ["User Email", "Workbook Citation Reference ID"]

    # All Type 1 will have 2 columns. a "Type 1 Name" and a "Type 1 Description"
    #   column. Outcome section is unique in that it has additional columns:
    #   [Outcome Type], [Population Name], [Population Description], [Timepoint Name]
    #   and [Timepoint Unit]

    # Collect all Type 1 section names.
    @lsof_type1_names = _gather_lsof_type1_names()
    lsof_type1_column_headers = _produce_lsof_type1_column_headers()
    column_header_elements << lsof_type1_column_headers if lsof_type1_column_headers.present?

    # Add header row to Assignments and Mappings worksheet.
    @ws_assignments_and_mappings.add_row(column_header_elements.flatten)
  end

  def _fill_existing_assignments_and_mappings_ws
    #!!! Placeholder for later. No needed yet.
  end  # def _fill_existing_assignments_and_mappings_ws

  def _gather_lsof_type1_names()
    # Iterate over all type 1 sections in project and return an array with names.
    return @project
      .extraction_forms_projects
      .first
      .extraction_forms_projects_sections
      .includes(:section)
      .joins(:extraction_forms_projects_section_type)
      .where(extraction_forms_projects_section_types:
        { name: "Type 1" })
      &.map(&:section)
      &.map(&:name)
  end

  def _produce_lsof_type1_column_headers()
    lsof_type1_column_headers = []

    # Re-org our list of Type 1 names to have "Outcomes" at the end.
    @lsof_type1_names&.append(@lsof_type1_names.delete("Outcomes")) if @lsof_type1_names.include? "Outcomes"
    @lsof_type1_names&.each do |name|
      case name
      when /Outcomes/
        lsof_type1_column_headers << [
          'Outcome Name',
          'Outcome Specific Measurement',
          'Outcome Type',
          'Population Name',
          'Population Description',
          'Timepoint Name',
          'Timepoint Unit'
        ]
      else
        lsof_type1_column_headers << [
          "#{name.singularize} Name",
          "#{name.singularize} Description"
        ]
      end
    end  # @lsof_type1_names.each do |name|

    return lsof_type1_column_headers
  end  # def _produce_lsof_type1_column_headers

  def _fill_workbook_citation_references_section(p)
    # Add header row.
    @ws_workbook_citation_references.add_row [
      'Workbook Citation Reference ID',
      'PMID',
      'Citation Name',
      'RefMan',
      'other_reference',
      'Authors'
    ]

    # Fill in the rest of the worksheet.
    @project.citations_projects.each_with_index do |citations_project, index|
      @ws_workbook_citation_references.add_row [
        index + 1,
        citations_project.citation.pmid.to_s,
        citations_project.citation.name.to_s,
        citations_project.refman.to_s,
        citations_project.other_reference.to_s,
        citations_project.citation.authors.to_s
      ]
    end
  end
end
