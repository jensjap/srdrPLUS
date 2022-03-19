require 'rubyXL'
require 'rubyXL/convenience_methods'

class ImportAssignmentsAndMappingsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    @dict_errors   = {}
    @wb_worksheets = {}
    @imported_file = ImportedFile.find(args.first)
    @project       = Project.find(@imported_file.project.id)

    buffer = @imported_file
      .content
      .download
    _parse_workbook(buffer)
    _sort_out_worksheets

    if @dict_errors[:wb_errors].blank?
      _process_workbook_citation_references_section
      _process_generic_type1_sections
      _process_outcomes_section
    end  # if @dict_errors[:wb_errors].blank?
  end  # def perform(*args)

  private

  def _process_outcomes_section
  end  # def _process_outcomes_section

  def _process_generic_type1_sections
  end  # def _process_generic_type1_sections

  def _process_workbook_citation_references_section
    @dict_citation_references = {}
    # We can assume the first is the only one. If there were multiple @dict_errors[:wb_errors]
    # would not have been blank and we would not have continued.
    ws = @wb_worksheets[:workbook_citation_references].first
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

    citation = Citation.find_by(pmid: pmid)
    return citation.id if citation.present?

    citation = Citation.find_by(name: citation_name)
    return citation.id if citation.present?

    @dict_errors[:ws_errors].present? \
      ? @dict_errors[:ws_errors] << "Unable to match Citation record to row: #{ row.cells.map(&:value) }" \
      : @dict_errors[:ws_errors] = ["Unable to match Citation record to row: #{ row.cells.map(&:value) }"]

    return nil
  end  # def _find_citation_in_db(row)

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

  def _parse_workbook(buffer)
    begin
      @wb = RubyXL::Parser.parse_buffer(buffer)
      @dict_errors[:parse_error] = nil
    rescue RuntimeError => e
      @dict_errors[:parse_error] = e
    end
  end  # def _parse_workbook(args)
end
