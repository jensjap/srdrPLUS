require "rubyXL"
require "s_import_job/worksheet_section"

class ImportHandler
  attr_reader :project_id, :data, :listOf_errors, :listOf_errors_processing_rows

  def initialize(u_id, p_id, force=false)  #{{{2
    @listOf_errors                      = Array.new
    @listOf_errors_processing_rows      = Array.new
    @listOf_errors_processing_questions = Array.new
    @listOf_email_recipients            = Array.new
    @user_id                            = u_id
    @project_id                         = p_id
    @local_file_path                    = nil
    @wb                                 = nil
    @headers                            = nil
    @data                               = nil
    @skipped_rows                       = 0
    @force_create_studies               = force

    # Dictionary keys we will use to find values
    @kq_key            = nil
    @pmid_key          = nil
    @internal_id_key   = nil
    @author_key        = nil
    @author_year_key   = nil
    @study_title_key   = nil
    @arm_key           = nil

    # Helps determine how to identify studies
    @study_identifier_type = nil
  end

  # @params [String] Path to file
  # @return [RubyXL::Workbook]
  def set_workbook(path)  #{{{2
    @local_file_path = path
    begin
      @wb = RubyXL::Parser.parse(@local_file_path)
    rescue RuntimeError=>e
      @listOf_errors << e
    end

    return @wb
  end

  #!!!
  def valid_workbook
    return true
  end

  def process_workbook
    @wb.worksheets.each do |ws|
      headers, data = _parse_data(ws)
      case ws.sheet_name
      when 'Design Details'
        worksheet = DesignDetails.new(headers, data)
      when 'Arms'
        worksheet = Arms.new(headers, data)
      when 'Arm Details'
        worksheet = ArmDetails.new(headers, data)
      when 'Outcomes'
        worksheet = Outcomes.new(headers, data)
      when 'Outcome Details'
        worksheet = OutcomeDetails.new(headers, data)
      when 'Baseline Characteristics'
        worksheet = BaselineCharacteristics.new(headers, data)
      when 'Results'
        worksheet = Results.new(headers, data)
      else
        if _guess_type(headers) == "Type 1"
          worksheet = GenericType1.new(headers, data)
        elsif _guess_type(headers) == "Type 2"
          worksheet = GenericType2.new(headers, data)
        else
          worksheet = GenericResults.new(headers, data)
        end
      end

      @listOf_errors_processing_rows << [worksheet.worksheet_type, worksheet.process_rows]
    end
  end

  def add_email_recipient(email)  #{{{2
    @listOf_email_recipients << email
  end

  private  #{{{2
  # The parsed data is returned in the form of an array of hashes,
  # where the keys of the hashes are the header values and the value
  # the cell content.
  # @params [RubyXL::Workbook]
  # @params [Array] Possible header strings
  # @return [Array of Hash]
  def _parse_data(worksheet, header_search=[])  #{{{2
    debugger
    raw_data = worksheet.extract_data
    if raw_data.length==0
      @listOf_errors << "Workbook might be empty."
      @data = []
    else
      @data = _transform_data(raw_data, header_search)
    end

    @headers = @data[0]
    @data = @data[1..-1]

    return @headers, @data
  end


  # Transform the 2 dimensional array of values into
  # an array of header-value hashes
  # @params [nested Array]
  # @params [Array]
  # @return [Array of Hash]
  def _transform_data(raw_data, header_search=[])  #{{{3
    transformed_data = Array.new
    i = _find_header_row_index(raw_data, header_search)
    transformed_data << _transform_header_row(i, raw_data)
    transformed_data.concat(_transform_data_rows(i, raw_data))

    return transformed_data
  end

  # @params [Integer]
  # @params [Array of Arrays]
  # @return [Hash]
  def _transform_header_row(i, raw_data)  #{{{3
    transformed_header_row = Hash.new
    raw_data[i].each do |key|
      if key.is_a? String
        key = CGI.unescapeHTML(key).strip
      end
      transformed_header_row[key] = key
    end

    return transformed_header_row
  end

  # Transform all rows except the header row into a list
  # of hashes, where the hash keys are the values of the
  # ith row
  # @params [Integer]
  # @params [Array of Arrays]
  # @return [Array of Hashes]
  def _transform_data_rows(i, raw_data)  #{{{3
    transformed_data_rows = Array.new
    headers = raw_data[i]
    raw_data.delete_at(i)
    raw_data.each do |row|
      transformed_row = Hash.new
      row.each_with_index do |c, ind|
        if c.is_a? String
          c = CGI.unescapeHTML(c).strip
        end

        key = headers[ind]
        if key.is_a? String
          key = CGI.unescapeHTML(key).strip
        end
        transformed_row[key] = c
      end
      transformed_data_rows << transformed_row
    end

    return transformed_data_rows
  end

  def _find_header_row_index(raw_data, header_search=[])  #{{{3
    #!!! Use the strings in array header_search to
    #    find the row index of the header

    return 0
  end

  #!!!
  def _validate_row(row)
    return true
  end

  #!!!
  def _process_row
  end

  #!!!
  def _guess_type(headers)
  end
end
