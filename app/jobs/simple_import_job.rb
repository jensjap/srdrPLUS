class SimpleImportJob
  DEFAULT_HEADERS = [
    'Extraction ID',
    'Consolidated',
    'Username',
    'Citation ID',
    'Citation Name',
    'RefMan',
    'PMID',
    'Authors',
    'Publication Date',
    'Key Questions'
  ]

  attr_reader :xlsx, :sheet_names

  def initialize(filepath)
    @xlsx = Roo::Excelx.new(filepath)
    @sheet_names = @xlsx.sheets
  end

  def valid_default_headers?
    @sheet_names.each do |sheet_name|
      next if sheet_name == 'Project Information'
      sheet = @xlsx.sheet(sheet_name)
      no_of_col = sheet.last_column
      return false unless !!no_of_col && no_of_col > 8 && sheet.row(1)[0..9] == DEFAULT_HEADERS
    end

    true
  end

  def info
    @xlsx.info
  end

  def sheet(sheet_name)
    @xlsx.sheet(sheet_name)
  end

  private

end