class WorksheetSection
  def initialize(headers, data)
    @headers = headers
    @data    = data
  end

  #!!!
  def process_rows  #{{{2
    @data.each_with_index do |row, ind|
      if _validate_row(row)
        puts "All's well. We can insert row #{ind + 2}."
        process_result = _process_row(row)
        unless process_result
          @listOf_errors_processing_rows << "Something went wrong while processing row #{ind + 2}."
        end
      else
        puts "Problem encountered. Skipped row #{ind + 2}."
        @listOf_errors_processing_rows << "Something was wrong with row #{ind + 2}. Skipped it."
        @skipped_rows += 1
        next
      end
    end

    # Notify user that processing is complete and if any errors occurred while processing rows.
    Notifier.simple_import_complete(@listOf_email_recipients, @skipped_rows,
                                    @listOf_errors_processing_rows,
                                    @listOf_errors_processing_questions).deliver

    # Delete local file
    begin
      FileUtils.rm @local_file_path
    rescue Errno::ENOENT => e
      puts "File already gone: " + e
    end

    return @listOf_errors_processing_rows
  end

  def worksheet_type
    return _return_worksheet_type
  end
end
