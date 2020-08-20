# == Schema Information
#
# Table name: question_row_columns
#
#  id                          :integer          not null, primary key
#  question_row_id             :integer
#  question_row_column_type_id :integer
#  name                        :string(255)
#  deleted_at                  :datetime
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class QuestionRowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :associate_default_question_row_column_type
  after_create :create_default_question_row_column_field

  after_save :ensure_question_row_column_fields

  belongs_to :question_row,             inverse_of: :question_row_columns
  belongs_to :question_row_column_type, inverse_of: :question_row_columns

  has_many :question_row_column_fields, dependent: :destroy, inverse_of: :question_row_column

  has_many :question_row_columns_question_row_column_options, dependent: :destroy, inverse_of: :question_row_column
  has_many :question_row_column_options, through: :question_row_columns_question_row_column_options, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  amoeba do
    enable
    clone [:question_row_columns_question_row_column_options, :question_row_column_fields]
  end

  #accepts_nested_attributes_for :question_row_column_fields
  accepts_nested_attributes_for :question_row_columns_question_row_column_options, allow_destroy: true


  delegate :question,      to: :question_row
  delegate :question_type, to: :question_row

  def field_validation_value_for(name)
    QuestionRowColumnsQuestionRowColumnOption.
      joins(:question_row_column, :question_row_column_option).
      where(question_row_column: self, question_row_column_options: { name: name }).
      first.
      name
  end

  private

    def associate_default_question_row_column_type
      # it is possible that this callback no longer serves a purpose after changes to other callbacks -Birol
      if not self.question_row_column_type.present?
        self.question_row_column_type = QuestionRowColumnType.find_by(name: 'text')
        self.save
      end
    end

    def create_default_question_row_column_field
      if not self.question_row_column_fields.present?
        self.question_row_column_fields.create
      end
    end

    def ensure_question_row_column_fields
      if self.question_row_column_type.name == QuestionRowColumnType::NUMERIC  # Numeric requires 2 fields.
        self.question_row_column_fields.create! while self.question_row_column_fields.length < 2
      end
    end
end
