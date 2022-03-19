class ExportAssignmentsAndMappingsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    project_id = args.first
    @project = Project.find(project_id)
    Axlsx::Package.new do |package|
      _add_worksheets(package)
      _set_arms_section_headers(package)
      _set_outcomes_section_headers(package)
      _set_generic_type1_section_headers(package)
      _fill_workbook_citation_references_section(package)
      _add_comments(package)

      return package
    end  # END Axlsx::Package.new do |package|
  end  # END def perform(*args)

  def _add_comments(p)
    @ws_arms.add_comment       ref: "B1", author: "Importer AI", visible: false, text: "Comma separated list of Workbook Citation Reference IDs"
    @ws_outcomes.add_comment   ref: "B1", author: "Importer AI", visible: false, text: "Comma separated list of Workbook Citation Reference IDs"
    @ws_generic_t1.add_comment ref: "B1", author: "Importer AI", visible: false, text: "Comma separated list of Workbook Citation Reference IDs"
    @ws_wbcr.add_comment       ref: "E1", author: "Importer AI", visible: false, text: "Surround each Author name only by brackets \"[]\""      
  end  # def _add_comments(p)

  def _fill_workbook_citation_references_section(p)
    @ws_wbcr.add_row [
      "Workbook Citation Reference ID",
      "PMID",
      "Citation Name",
      "RefMan",
      "Authors"
    ]
    @project.citations.each_with_index do |citation, index|
      @ws_wbcr.add_row [
        index + 1,
        citation.pmid,
        citation.name,
        citation.refman,
        citation.author_list_for_citation_references_in_brackets
      ]
    end  # @project.citations.each_with_index do |citation, index|
  end  # END def _fill_workbook_citation_references_section(p)

  def _set_generic_type1_section_headers(p)
    @ws_generic_t1.add_row [
      "User Email",
      "Workbook Citation Reference ID",
      "Generic Type 1 Name",
      "Generic Type 1 Description"
    ]
    @project.projects_users.each do |pu|
      @ws_generic_t1.add_row [pu.user.email]
    end  # END @project.projects_users.each do |pu|
  end  # END def _set_generic_type1_section_headers(p)

  def _set_outcomes_section_headers(p)
    @ws_outcomes.add_row [
      "User Email",
      "Workbook Citation Reference ID",
      "Outcome Type",
      "Outcome Name",
      "Outcome Specific Measurement",
      "Population Name",
      "Population Description",
      "Timepoint Name",
      "Timepoint Unit"
    ]
    @project.projects_users.each do |pu|
      @ws_outcomes.add_row [pu.user.email]
    end  # END @project.projects_users.each do |pu|
  end  # END def _set_outcomes_section_headers(p)

  def _set_arms_section_headers(p)
    @ws_arms.add_row [
      "User Email",
      "Workbook Citation Reference ID",
      "Arm Name",
      "Arm Description"
    ]
    @project.projects_users.each do |pu|
      @ws_arms.add_row [pu.user.email]
    end  # END project_users = @project.projects_users.each do |pu|
  end  # END def _set_arms_section_headers(p)

  def _add_worksheets(p)
    @ws_arms       = p.workbook.add_worksheet(name: "Arms")
    @ws_outcomes   = p.workbook.add_worksheet(name: "Outcomes")
    @ws_generic_t1 = p.workbook.add_worksheet(name: "Generic Type 1")
    # Workbook Citation References
    #   The "Workbook Citation Reference ID" is workbook specific and arbitrary...there is
    #   no relation to any IDs within the application. Internal workbook use only.
    @ws_wbcr = p.workbook.add_worksheet(name: "Workbook Citation References")
  end  # END def add_user_sheet
end
