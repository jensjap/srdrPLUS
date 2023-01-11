module ImportHelpers
  module ImportAssignmentsAndMappingsJobHelpers
    def hello
      puts 'Hello Sir'
    end

    # Attempting to fetch `imported_file.content.download`
    # We will make 5 attempts waiting 2 seconds between each attempt.
    # If successful return the buffer, else raise exception.
    def get_buffer_from_imported_file(imported_file)
      cnt = 1
      until cnt > 5
        begin
          buffer = imported_file.content.download
        rescue ActiveStorage::FileNotFoundError => exception
          print_msg_and_wait(cnt, exception, 2)
          cnt += 1
        else
          break
        end
      end
      raise 'Unable to get imported file buffer.' unless buffer.present?

      buffer
    end

    def print_msg_and_wait(attempt_cnt, exception, duration)
      puts "Attempt ##{attempt_cnt}"
      puts exception
      puts 'Waiting ...'
      sleep duration
    end
  end
end
