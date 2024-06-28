# == Schema Information
#
# Table name: questions
#
#  id                                   :integer          not null, primary key
#  extraction_forms_projects_section_id :integer
#  name                                 :text(65535)
#  description                          :text(65535)
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  pos                                  :integer          default(999999)
#

class Question < ApplicationRecord
  default_scope { order(:pos, :id) }

  include SharedSuggestableMethods

  attr_accessor :skip_callbacks

  after_create :create_default_question_row, unless: :skip_callbacks
  after_create :associate_kqs
  after_save :ensure_matrix_column_headers, unless: :skip_callbacks

  belongs_to :extraction_forms_projects_section, inverse_of: :questions

  has_many :dependencies, as: :dependable, dependent: :destroy

  has_many :key_questions_projects_questions, dependent: :destroy, inverse_of: :question
  has_many :key_questions_projects, through: :key_questions_projects_questions, dependent: :destroy

  has_many :question_rows, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :question
  has_many :question_row_columns, through: :question_rows
  has_many :question_row_column_fields, through: :question_row_columns

  accepts_nested_attributes_for :question_rows

  delegate :extraction_forms_project, to: :extraction_forms_projects_section
  delegate :project,                  to: :extraction_forms_project
  delegate :section,                  to: :extraction_forms_projects_section

  amoeba do
    enable
    exclude_association :dependencies
    exclude_association :key_questions_projects_questions

    customize(lambda { |_original, cloned|
      cloned.skip_callbacks = true
    })
  end

  # Returns the question type based on how many how many rows/columns/answer choices the question has.
  def question_type
    return 'Single' if question_rows.length == 1 && question_rows.first.question_row_columns.length == 1

    'Matrix'
  end

  # Checks whether this is dependent on argument.
  #
  # (prerequisitable) -> Boolean
  def depends_on?(prerequisitable)
    dependencies.any? { |d| d.prerequisitable == prerequisitable }
  end

  # Toggle dependency.
  #
  # (prerequisitable) -> nil
  def toggle_dependency(prerequisitable)
    # Capture the deleted dependency.
    dependency = dependencies.delete(dependencies.where(prerequisitable:))

    # If no dependency was deleted then we add it.
    dependencies << Dependency.create(prerequisitable:) if dependency.blank?

    nil
  end

  def duplicate
    duplicated_question = nil
    Question.transaction do
      duplicated_question = amoeba_dup
      duplicated_question.save
    end
    question_rows.each_with_index do |question_row, question_row_index|
      question_row.question_row_columns.each_with_index do |question_row_column, question_row_column_index|
        duplicated_qrc = duplicated_question.question_rows[question_row_index].question_row_columns[question_row_column_index]

        case question_row_column.question_row_column_type_id
        when 2
          numeric_qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_by(
            question_row_column:,
            question_row_column_option_id: 4
          )
          allow_equality = numeric_qrcqrco.name

          duplicated_qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_by(
            question_row_column: duplicated_qrc,
            question_row_column_option_id: 4
          )
          duplicated_qrcqrco.update(name: allow_equality)
        when 5, 7
          QuestionRowColumnsQuestionRowColumnOption
            .where(question_row_column:,
                   question_row_column_option_id: 1).each_with_index do |multiplechoice_qrcqrco, qrcqrco_index|
            duplicated_qrcqrco = QuestionRowColumnsQuestionRowColumnOption.where(
              question_row_column: duplicated_qrc,
              question_row_column_option_id: 1
            )[qrcqrco_index]
            if multiplechoice_qrcqrco.followup_field.present?
              FollowupField.find_or_create_by(question_row_columns_question_row_column_option: duplicated_qrcqrco)
            else
              FollowupField.find_by(question_row_columns_question_row_column_option: duplicated_qrcqrco)&.destroy
            end
          end
        end
      end
    end
    duplicated_question
  end

  private

  # By default we associate all key_questions_projects to the question.
  def associate_kqs
    project.key_questions_projects.each do |kqp|
      kqp.questions << self
    end
  end

  def create_default_question_row
    question_rows.create
  end

  # !!! May need to rethink this.
  #    Who is actually responsible for this concern: Question,
  #    QuestionRow or QuestionRowColumn.
  def ensure_matrix_column_headers
    first_row = question_rows.first
    rest_rows = question_rows[1..-1]

    column_headers = []

    first_row.question_row_columns.each do |c|
      column_headers << c.name
    end

    rest_rows.each do |r|
      r.question_row_columns.each_with_index do |rc, idx|
        rc.update(name: column_headers[idx])
      end
    end
  end
end
