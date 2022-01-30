class ExportAssignmentListJob < ApplicationJob
  queue_as :default

  def perform(*args)
    project_id = args.first
    @project = Project.find(project_id)
    Axlsx::Package.new do |package|
      _add_worksheets(package)
      _fill_user_list(package)
      _fill_citation_list(package)
      _set_assignment_list_headers(package)

      return package
    end  # END Axlsx::Package.new do |package|
  end  # END def perform(*args)

  def _set_assignment_list_headers(p)
    ws = p.workbook.sheet_by_name("Assignment List")
    ws.add_row ["User ID", "User Email", "Citation ID", "Citation Name"]
  end  # END def _set_assignment_list_headers(p)

  def _fill_citation_list(p)
    ws = p.workbook.sheet_by_name("Citation List")
    ws.add_row ["ID", "Name"]
    @project.citations_projects.each do |cp|
      ws.add_row [cp.citation.id, cp.citation.name]
    end  # END @project.citations_projects.each do |cp|
  end  # END def _fill_citation_list(p)

  def _fill_user_list(p)
    ws = p.workbook.sheet_by_name("User List")
    ws.add_row ["ID", "Email"]
    @project.projects_users.each do |pu|
      ws.add_row [pu.user.id, pu.user.email]
    end  # END project_users = @project.projects_users.each do |pu|
  end  # END def _fill_user_list(p)

  def _add_worksheets(p)
    ws_ul = p.workbook.add_worksheet(name: "User List")
    ws_cl = p.workbook.add_worksheet(name: "Citation List")
    ws_al = p.workbook.add_worksheet(name: "Assignment List")
  end  # END def add_user_sheet
end
