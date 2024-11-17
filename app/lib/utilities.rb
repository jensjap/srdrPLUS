module Utilities
  class << self
    def encode_to_utf8(string)
      if string.valid_encoding?
        # Force encoding if necessary
        string = string.force_encoding('UTF-8') if string.encoding != Encoding::UTF_8
      else
        # Handle invalid encoding by replacing problematic characters
        string = string.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
      end

      string
    end
  end
end
