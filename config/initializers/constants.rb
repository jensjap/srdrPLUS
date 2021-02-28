  DEFAULT_QRC_TYPES = ['Text Field (alphanumeric)', 
     'Numeric Field (numeric)',
     'Checkbox (select multiple)', 
     'Dropdown (select one)', 
     'Radio (select one)',
     'Select one (with write-in option)', 'Select multiple (with write-in option)'].zip(QuestionRowColumnType.where(id: [1, 2, 5, 6, 7, 8, 9]).pluck(:id)).freeze

  ANSWER_CHOICE_QRCO = QuestionRowColumnOption.find_by(name: "answer_choice")
