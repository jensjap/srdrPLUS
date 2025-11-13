# Service for comparing extraction forms between projects
# to determine if they are functionally identical
class ExtractionFormComparisonService
  attr_reader :project1, :project2, :differences

  def initialize(project1, project2)
    @project1 = project1
    @project2 = project2
    @differences = []
  end

  # Compare the first extraction_forms_project of two projects
  # Returns true if functionally identical, false otherwise
  def first_extraction_forms_identical?
    efp1 = project1.extraction_forms_projects.first
    efp2 = project2.extraction_forms_projects.first

    return false unless efp1.present? && efp2.present?

    compare_extraction_forms_projects(efp1, efp2)
  end

  # Get detailed differences found during comparison
  def get_differences
    @differences
  end

  private

  def compare_extraction_forms_projects(efp1, efp2)
    @differences = []

    # Compare extraction_forms_project_type_id
    unless efp1.extraction_forms_project_type_id == efp2.extraction_forms_project_type_id
      @differences << "Different extraction_forms_project_type_id: #{efp1.extraction_forms_project_type_id} vs #{efp2.extraction_forms_project_type_id}"
      return false
    end

    # Compare extraction_forms_projects_sections
    return false unless compare_sections(efp1, efp2)

    # If we made it here, they are identical
    @differences.empty?
  end

  def compare_sections(efp1, efp2)
    sections1 = efp1.extraction_forms_projects_sections.includes(
      :section,
      :extraction_forms_projects_section_type,
      :extraction_forms_projects_section_option,
      questions: [
        :dependencies,
        :key_questions_projects,
        { question_rows: { question_row_columns: [
          :question_row_column_fields,
          { question_row_columns_question_row_column_options: %i[question_row_column_option followup_field] }
        ] } }
      ]
    ).order(:pos, :id)

    sections2 = efp2.extraction_forms_projects_sections.includes(
      :section,
      :extraction_forms_projects_section_type,
      :extraction_forms_projects_section_option,
      questions: [
        :dependencies,
        :key_questions_projects,
        { question_rows: { question_row_columns: [
          :question_row_column_fields,
          { question_row_columns_question_row_column_options: %i[question_row_column_option followup_field] }
        ] } }
      ]
    ).order(:pos, :id)

    # Compare section counts
    if sections1.count != sections2.count
      @differences << "Different number of sections: #{sections1.count} vs #{sections2.count}"
      return false
    end

    # Compare each section pair
    sections1.zip(sections2).each_with_index do |(s1, s2), index|
      return false unless compare_section_pair(s1, s2, index)
    end

    true
  end

  def compare_section_pair(section1, section2, index)
    # Compare section name
    if section1.section.name.to_s != section2.section.name.to_s
      @differences << "Section #{index}: Different section names: '#{section1.section.name}' vs '#{section2.section.name}'"
      return false
    end

    # Compare section type
    if section1.extraction_forms_projects_section_type_id != section2.extraction_forms_projects_section_type_id
      @differences << "Section #{index} (#{section1.section.name}): Different section types"
      return false
    end

    # Compare hidden status
    if section1.hidden != section2.hidden
      @differences << "Section #{index} (#{section1.section.name}): Different hidden status: #{section1.hidden} vs #{section2.hidden}"
      return false
    end

    # # Compare position
    # if section1.pos != section2.pos
    #   @differences << "Section #{index} (#{section1.section.name}): Different positions: #{section1.pos} vs #{section2.pos}"
    #   return false
    # end

    # Compare link_to_type1
    link1_section_name = section1.link_to_type1&.section&.name
    link2_section_name = section2.link_to_type1&.section&.name
    if link1_section_name.to_s != link2_section_name.to_s
      @differences << "Section #{index} (#{section1.section.name}): Different link_to_type1: '#{link1_section_name}' vs '#{link2_section_name}'"
      return false
    end

    # Compare section options
    return false unless compare_section_options(section1, section2, index)

    # Compare questions
    return false unless compare_questions(section1, section2, index)

    true
  end

  def compare_section_options(section1, section2, section_index)
    option1 = section1.extraction_forms_projects_section_option
    option2 = section2.extraction_forms_projects_section_option

    return true if option1.nil? && option2.nil?

    if option1.nil? || option2.nil?
      @differences << "Section #{section_index} (#{section1.section.name}): One has options, the other doesn't"
      return false
    end

    # Compare relevant option attributes
    %i[by_type1 include_total].each do |attr|
      if option1.send(attr) != option2.send(attr)
        @differences << "Section #{section_index} (#{section1.section.name}): Different #{attr}: #{option1.send(attr)} vs #{option2.send(attr)}"
        return false
      end
    end

    true
  end

  def compare_questions(section1, section2, section_index)
    questions1 = section1.questions.order(:pos, :id)
    questions2 = section2.questions.order(:pos, :id)

    if questions1.count != questions2.count
      @differences << "Section #{section_index} (#{section1.section.name}): Different number of questions: #{questions1.count} vs #{questions2.count}"
      return false
    end

    questions1.zip(questions2).each_with_index do |(q1, q2), q_index|
      return false unless compare_question_pair(q1, q2, section_index, q_index, section1.section.name)
    end

    true
  end

  def compare_question_pair(q1, q2, section_index, q_index, section_name)
    # Compare question name
    if q1.name.to_s != q2.name.to_s
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}: Different names: '#{q1.name}' vs '#{q2.name}'"
      return false
    end

    # Compare question description
    if q1.description != q2.description
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}: Different descriptions"
      return false
    end

    # Compare question rows
    return false unless compare_question_rows(q1, q2, section_index, q_index, section_name)

    # Compare dependencies
    return false unless compare_dependencies(q1, q2, section_index, q_index, section_name)

    # Compare key questions
    return false unless compare_question_key_questions(q1, q2, section_index, q_index, section_name)

    true
  end

  def compare_question_rows(q1, q2, section_index, q_index, section_name)
    rows1 = q1.question_rows.order(:id)
    rows2 = q2.question_rows.order(:id)

    if rows1.count != rows2.count
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}: Different number of question rows: #{rows1.count} vs #{rows2.count}"
      return false
    end

    rows1.zip(rows2).each_with_index do |(r1, r2), r_index|
      return false unless compare_question_row_pair(r1, r2, section_index, q_index, r_index, section_name)
    end

    true
  end

  def compare_question_row_pair(r1, r2, section_index, q_index, r_index, section_name)
    # Compare row name
    if r1.name.to_s != r2.name.to_s
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}: Different names: '#{r1.name}' vs '#{r2.name}'"
      return false
    end

    # Compare question_row_columns
    cols1 = r1.question_row_columns.order(:id)
    cols2 = r2.question_row_columns.order(:id)

    if cols1.count != cols2.count
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}: Different number of columns: #{cols1.count} vs #{cols2.count}"
      return false
    end

    cols1.zip(cols2).each_with_index do |(c1, c2), c_index|
      unless compare_question_row_column_pair(c1, c2, section_index, q_index, r_index, c_index, section_name)
        return false
      end
    end

    true
  end

  def compare_question_row_column_pair(c1, c2, section_index, q_index, r_index, c_index, section_name)
    # Compare column name
    if c1.name.to_s != c2.name.to_s
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different names: '#{c1.name}' vs '#{c2.name}'"
      return false
    end

    # Compare column type
    if c1.question_row_column_type_id != c2.question_row_column_type_id
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different column types"
      return false
    end

    # Compare question_row_column_fields
    fields1 = c1.question_row_column_fields.order(:id)
    fields2 = c2.question_row_column_fields.order(:id)

    if fields1.count != fields2.count
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different number of fields: #{fields1.count} vs #{fields2.count}"
      return false
    end

    fields1.zip(fields2).each_with_index do |(f1, f2), f_index|
      unless compare_question_row_column_field_pair(f1, f2, section_index, q_index, r_index, c_index, f_index,
                                                    section_name)
        return false
      end
    end

    # Compare question_row_columns_question_row_column_options
    return false unless compare_question_row_column_options(c1, c2, section_index, q_index, r_index, c_index,
                                                            section_name)

    true
  end

  def compare_question_row_column_field_pair(f1, f2, section_index, q_index, r_index, c_index, f_index, section_name)
    # Compare field name (fields don't have a type - the type is on the parent question_row_column)
    if f1.name.to_s != f2.name.to_s
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}, Field #{f_index}: Different names: '#{f1.name}' vs '#{f2.name}'"
      return false
    end

    true
  end

  def compare_dependencies(q1, q2, section_index, q_index, section_name)
    deps1 = q1.dependencies.order(:id)
    deps2 = q2.dependencies.order(:id)

    if deps1.count != deps2.count
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}: Different number of dependencies: #{deps1.count} vs #{deps2.count}"
      return false
    end

    # NOTE: Comparing dependencies by structure and relative position, not by actual IDs
    # since the prerequisite IDs will be different between projects
    deps1.zip(deps2).each_with_index do |(d1, d2), d_index|
      if d1.prerequisitable_type != d2.prerequisitable_type
        @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Dependency #{d_index}: Different prerequisitable_type: '#{d1.prerequisitable_type}' vs '#{d2.prerequisitable_type}'"
        return false
      end

      # Compare prerequisite question relative positions within their section
      prereq_q1 = d1.prerequisitable.question
      prereq_q2 = d2.prerequisitable.question

      section1_questions = prereq_q1.extraction_forms_projects_section.questions.order(:pos, :id).to_a
      section2_questions = prereq_q2.extraction_forms_projects_section.questions.order(:pos, :id).to_a

      prereq_q1_relative_index = section1_questions.find_index { |q| q.id == prereq_q1.id }
      prereq_q2_relative_index = section2_questions.find_index { |q| q.id == prereq_q2.id }

      if prereq_q1_relative_index != prereq_q2_relative_index
        @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Dependency #{d_index}: Different prerequisite question relative position: #{prereq_q1_relative_index} vs #{prereq_q2_relative_index} (section has #{section1_questions.count} questions)"
        return false
      end

      # For field and option prerequisites, also compare their relative positions within the question
      case d1.prerequisitable_type
      when 'QuestionRowColumnField'
        return false unless compare_field_prerequisite_positions(d1, d2, section_index, q_index, d_index, section_name)
      when 'QuestionRowColumnsQuestionRowColumnOption'
        return false unless compare_option_prerequisite_positions(d1, d2, section_index, q_index, d_index, section_name)
      end
    end

    true
  end

  def compare_field_prerequisite_positions(d1, d2, section_index, q_index, d_index, section_name)
    field1 = d1.prerequisitable
    field2 = d2.prerequisitable

    # Get the row and column positions
    row1_index = field1.question_row_column.question_row.question.question_rows.index(field1.question_row_column.question_row)
    row2_index = field2.question_row_column.question_row.question.question_rows.index(field2.question_row_column.question_row)

    if row1_index != row2_index
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Dependency #{d_index}: Different prerequisite row position: #{row1_index} vs #{row2_index}"
      return false
    end

    col1_index = field1.question_row_column.question_row.question_row_columns.index(field1.question_row_column)
    col2_index = field2.question_row_column.question_row.question_row_columns.index(field2.question_row_column)

    if col1_index != col2_index
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Dependency #{d_index}: Different prerequisite column position: #{col1_index} vs #{col2_index}"
      return false
    end

    true
  end

  def compare_option_prerequisite_positions(d1, d2, section_index, q_index, d_index, section_name)
    option1 = d1.prerequisitable
    option2 = d2.prerequisitable

    # Get the row and column positions
    row1_index = option1.question_row_column.question_row.question.question_rows.index(option1.question_row_column.question_row)
    row2_index = option2.question_row_column.question_row.question.question_rows.index(option2.question_row_column.question_row)

    if row1_index != row2_index
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Dependency #{d_index}: Different prerequisite row position: #{row1_index} vs #{row2_index}"
      return false
    end

    col1_index = option1.question_row_column.question_row.question_row_columns.index(option1.question_row_column)
    col2_index = option2.question_row_column.question_row.question_row_columns.index(option2.question_row_column)

    if col1_index != col2_index
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Dependency #{d_index}: Different prerequisite column position: #{col1_index} vs #{col2_index}"
      return false
    end

    # For options, compare the relative position within the column's answer choices (not all options)
    # Filter to only answer_choice options with non-empty names (the actual selectable choices)
    # This handles cases where pos is still 999999 (default) vs 1 (reordered)
    column1_options = option1.question_row_column.question_row_columns_question_row_column_options
                             .select { |opt| opt.question_row_column_option.name == 'answer_choice' && opt.name.to_s.present? }
                             .sort_by { |opt| [opt.pos, opt.id] }
    column2_options = option2.question_row_column.question_row_columns_question_row_column_options
                             .select { |opt| opt.question_row_column_option.name == 'answer_choice' && opt.name.to_s.present? }
                             .sort_by { |opt| [opt.pos, opt.id] }

    option1_relative_index = column1_options.find_index { |opt| opt.id == option1.id }
    option2_relative_index = column2_options.find_index { |opt| opt.id == option2.id }

    if option1_relative_index != option2_relative_index
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Dependency #{d_index}: Different prerequisite option relative position: #{option1_relative_index} vs #{option2_relative_index} (among #{column1_options.count} answer choices)"
      return false
    end

    true
  end

  def compare_question_key_questions(q1, q2, section_index, q_index, section_name)
    kqps1 = q1.key_questions_projects.includes(:key_question).order('key_questions.name')
    kqps2 = q2.key_questions_projects.includes(:key_question).order('key_questions.name')

    if kqps1.count != kqps2.count
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}: Different number of key questions: #{kqps1.count} vs #{kqps2.count}"
      return false
    end

    kqps1.zip(kqps2).each_with_index do |(kqp1, kqp2), kq_index|
      if kqp1.key_question.name.to_s != kqp2.key_question.name.to_s
        @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Key Question #{kq_index}: Different names: '#{kqp1.key_question.name}' vs '#{kqp2.key_question.name}'"
        return false
      end
    end

    true
  end

  def compare_question_row_column_options(c1, c2, section_index, q_index, r_index, c_index, section_name)
    type_name = c1.question_row_column_type.name

    case type_name
    when QuestionRowColumnType::TEXT
      # For text fields, compare min and max character length
      compare_text_field_options(c1, c2, section_index, q_index, r_index, c_index, section_name)

    when QuestionRowColumnType::NUMERIC, QuestionRowColumnType::NUMERIC_RANGE, QuestionRowColumnType::SCIENTIFIC
      # For numeric fields, compare "Allow equality", min, and max
      compare_numeric_field_options(c1, c2, section_index, q_index, r_index, c_index, section_name)

    when *QuestionRowColumnType::OPTION_SELECTION_TYPES
      # For checkbox, dropdown, radio, select2: compare answer choices
      compare_answer_choice_options(c1, c2, section_index, q_index, r_index, c_index, section_name, type_name)

    else
      # For other types, no specific comparison needed
      true
    end
  end

  def compare_text_field_options(c1, c2, section_index, q_index, r_index, c_index, section_name)
    min_length1 = c1.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'min_length'
    end&.name.to_s
    min_length2 = c2.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'min_length'
    end&.name.to_s

    max_length1 = c1.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'max_length'
    end&.name.to_s
    max_length2 = c2.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'max_length'
    end&.name.to_s

    if min_length1 != min_length2
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different min length: '#{min_length1}' vs '#{min_length2}'"
      return false
    end

    if max_length1 != max_length2
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different max length: '#{max_length1}' vs '#{max_length2}'"
      return false
    end

    true
  end

  def compare_numeric_field_options(c1, c2, section_index, q_index, r_index, c_index, section_name)
    # "additional_char" represents "Allow ~, <, >, ≤, ≥"
    additional_char1 = c1.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'additional_char'
    end&.name.to_s
    additional_char2 = c2.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'additional_char'
    end&.name.to_s

    min_value1 = c1.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'min_value'
    end&.name.to_s
    min_value2 = c2.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'min_value'
    end&.name.to_s

    max_value1 = c1.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'max_value'
    end&.name.to_s
    max_value2 = c2.question_row_columns_question_row_column_options.find do |opt|
      opt.question_row_column_option.name == 'max_value'
    end&.name.to_s

    if additional_char1 != additional_char2
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different 'Allow equality' setting: '#{additional_char1}' vs '#{additional_char2}'"
      return false
    end

    if min_value1 != min_value2
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different min value: '#{min_value1}' vs '#{min_value2}'"
      return false
    end

    if max_value1 != max_value2
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different max value: '#{max_value1}' vs '#{max_value2}'"
      return false
    end

    true
  end

  def compare_answer_choice_options(c1, c2, section_index, q_index, r_index, c_index, section_name, type_name)
    # Filter to only answer_choice options with non-empty names (the actual choices)
    options1 = c1.question_row_columns_question_row_column_options
                 .select { |opt| opt.question_row_column_option.name == 'answer_choice' && opt.name.to_s.present? }
                 .sort_by { |opt| [opt.pos, opt.id] }

    options2 = c2.question_row_columns_question_row_column_options
                 .select { |opt| opt.question_row_column_option.name == 'answer_choice' && opt.name.to_s.present? }
                 .sort_by { |opt| [opt.pos, opt.id] }

    if options1.count != options2.count
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}: Different number of answer choices: #{options1.count} vs #{options2.count}"
      return false
    end

    # Only compare followup fields for checkbox and radio types
    compare_followup = [QuestionRowColumnType::CHECKBOX, QuestionRowColumnType::RADIO].include?(type_name)

    options1.zip(options2).each_with_index do |(o1, o2), o_index|
      unless compare_question_row_column_option_pair(o1, o2, section_index, q_index, r_index, c_index, o_index,
                                                     section_name, compare_followup)
        return false
      end
    end

    true
  end

  def compare_question_row_column_option_pair(o1, o2, section_index, q_index, r_index, c_index, o_index, section_name,
                                              compare_followup = false)
    # Compare option type (e.g., answer_choice, min_length, max_length, etc.)
    if o1.question_row_column_option.name != o2.question_row_column_option.name
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}, Option #{o_index}: Different option types: '#{o1.question_row_column_option.name}' vs '#{o2.question_row_column_option.name}'"
      return false
    end

    # Compare option value/name (the actual choice text or constraint value)
    if o1.name.to_s != o2.name.to_s
      @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}, Option #{o_index} (#{o1.question_row_column_option.name}): Different values: '#{o1.name}' vs '#{o2.name}'"
      return false
    end

    # Only compare followup_field presence for checkbox and radio types
    if compare_followup
      has_followup1 = o1.followup_field.present?
      has_followup2 = o2.followup_field.present?

      if has_followup1 != has_followup2
        @differences << "Section #{section_index} (#{section_name}), Question #{q_index}, Row #{r_index}, Column #{c_index}, Option #{o_index} (#{o1.question_row_column_option.name}): Different followup field presence: #{has_followup1} vs #{has_followup2}"
        return false
      end
    end

    true
  end
end
