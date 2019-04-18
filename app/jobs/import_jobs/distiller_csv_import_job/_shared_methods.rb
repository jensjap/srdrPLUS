def process_headers headers
  current_question_number = 1
  current_question_type = "text"
  options = []

  if headers.length <= 3 or headers[0] != "Refid" or headers[1] != "User" or headers[2] != "Level"
    ## there has to be at least 4 columns, first 3 is refid, user and level, 4+ is questions
    return false
  end

  @question_dict = {}

  headers[3..headers.length-1].each do |raw_header|
    header = raw_header.strip
    if @question_dict[header]

    end
  end
end



class QuestionDefinition
  attr_accessor :type, :name, :options
  def initialize type, name, options
    @type = type
    @name = name
    @options = options
  end
end