# == Schema Information
#
# Table name: question_rows
#
#  id          :integer          not null, primary key
#  question_id :integer
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class QuestionRow < ApplicationRecord
  attr_accessor :skip_callbacks, :is_amoeba_copy

  amoeba do
    enable

    customize(lambda { |_, copy|
      copy.skip_callbacks = true
      copy.is_amoeba_copy = true
    })
  end

  after_create :create_default_question_row_columns, unless: :skip_callbacks

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :question, inverse_of: :question_rows

  has_many :question_row_columns, -> { order(id: :asc) }, dependent: :destroy, inverse_of: :question_row

  accepts_nested_attributes_for :question_row_columns

  delegate :project, to: :question
  delegate :question_type, to: :question

  def duplicate
    duplicated_question_row = nil
    QuestionRow.transaction do
      duplicated_question_row = amoeba_dup
      duplicated_question_row.save
    end
    question_row_columns.each_with_index do |question_row_column, question_row_column_index|
      duplicated_qrc = duplicated_question_row.question_row_columns[question_row_column_index]

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

  def add_columns_to_all_siblings
    question.question_rows.all? do |question_row|
      question_row.question_row_columns.create(question_row_column_type: QuestionRowColumnType.find_by(name: 'text'))
    end
  end

  private

  def create_default_question_row_columns
    col_size = question.question_rows.first.question_row_columns.size
    col_size = 1 if col_size.zero?
    question.question_rows.each do |question_row|
      diff = col_size - question_row.question_row_columns.size
      until diff < 1
        question_row.question_row_columns.create(question_row_column_type: QuestionRowColumnType.find_by(name: 'text'))
        diff -= 1
      end
    end
    #   if question.question_rows.first.question_row_columns.length == 0
    #     # If this is the first/only row in the matrix then we default to creating
    #     # (arbitrarily) 1 column.
    #     question_row_columns.create(
    #       question_row_column_type: QuestionRowColumnType.find_by(name: 'text')
    #     )
    #   else
    #     # Otherwise, create the same number of columns as first row has.
    #     question.question_rows.first.question_row_columns.count.times do |_c|
    #       question_row_columns.create(
    #         question_row_column_type: QuestionRowColumnType.find_by(name: 'text')
    #       )
    #     end
    #   end

    #   # !!!!! Do we need this still????
    #   # Newly created question_row_columns do not have their name field set.
    #   # This triggers after_save :ensure_matrix_column_headers callback in
    #   # question model to set the name field.
    #   question.save
  end

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
