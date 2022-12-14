class SimpleExportJob::ExporterBase
  RESERVED_WORKSHEET_NAMES = [
    'Desc. Statistics',
    'BAC Comparisons',
    'WAC Comparisons',
    'NET Differences',
    'Continuous - Desc. Statistics',
    'Categorical - Desc. Statistics',
    'Continuous - BAC Comparisons',
    'Categorical - BAC Comparisons',
    'WAC Comparisons',
    'NET Differences'
  ].freeze

  def initialize(package, project, highlight, wrap)
    @package = package
    @project = project
    @highlight = highlight
    @wrap = wrap
  end

  def ensure_unique_sheet_name(name)
    counter = 0
    candidate_name = name
    while (@package.workbook.worksheets.any? do |worksheet|
             worksheet.name == candidate_name
           end) || RESERVED_WORKSHEET_NAMES.include?(candidate_name)
      counter += 1
      candidate_name = "#{name}_#{counter}"
    end
    candidate_name
  end

  def build_project_information_section
    # Sheet with basic project information.
    @package.workbook.add_worksheet(name: 'Project Information') do |sheet|
      sheet.add_row ['Project Information:'], style: [@highlight]
      sheet.add_row ['Name',                    @project.name]
      sheet.add_row ['Description',             @project.description], style: [@wrap]
      sheet.add_row ['Attribution',             @project.attribution]
      sheet.add_row ['Methodology Description', @project.methodology_description]
      sheet.add_row ['Prospero',                @project.prospero],                types: [nil, :string]
      sheet.add_row ['DOI',                     @project.doi],                     types: [nil, :string]
      sheet.add_row ['Notes',                   @project.notes]
      sheet.add_row ['Funding Source',          @project.funding_source]

      # Project member list.
      sheet.add_row ['Project Member List:'], style: [@highlight]
      sheet.add_row ['Username', 'First Name', 'Middle Name', 'Last Name', 'Email', 'Extraction ID']
      @project.members.each do |user|
        sheet.add_row [
          user.username,
          user.first_name,
          user.middle_name,
          user.last_name,
          user.email,
          Extraction.where(project: @project, user:).pluck(:id)
        ]
      end

      # Re-apply the styling for the new cells before closing the sheet.
      sheet.column_widths nil
    end
  end
end
