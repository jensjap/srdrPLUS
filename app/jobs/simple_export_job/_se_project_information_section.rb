def build_project_information_section(p, project, highlight, wrap)
  # Sheet with basic project information.
  p.workbook.add_worksheet(name: 'Project Information') do |sheet|
    sheet.add_row ['Project Information:'],                                     style: [highlight]
    sheet.add_row ['Name',                    project.name]
    sheet.add_row ['Description',             project.description],             style: [wrap]
    sheet.add_row ['Attribution',             project.attribution]
    sheet.add_row ['Methodology Description', project.methodology_description]
    sheet.add_row ['Prospero',                project.prospero],                types: [nil, :string]
    sheet.add_row ['DOI',                     project.doi],                     types: [nil, :string]
    sheet.add_row ['Notes',                   project.notes]
    sheet.add_row ['Funding Source',          project.funding_source]

    # Project member list.
    sheet.add_row ['Project Member List:'],                                     style: [highlight]
    sheet.add_row ['Username', 'First Name', 'Middle Name', 'Last Name', 'Email', 'Extraction ID']
    project.members.each do |user|
      sheet.add_row [
        user.profile.username,
        user.profile.first_name,
        user.profile.middle_name,
        user.profile.last_name,
        user.email,
        Extraction.by_project_and_user(project.id, user.id).pluck(:id)
      ]
    end

    # Re-apply the styling for the new cells before closing the sheet.
    sheet.column_widths nil
  end
end
