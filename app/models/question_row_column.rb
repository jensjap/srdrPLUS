class QuestionRowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :associate_default_question_row_column_type
  after_create :create_default_question_row_column_options
  after_create :create_default_question_row_column_field

  after_save :ensure_question_row_column_fields

  belongs_to :question_row,             inverse_of: :question_row_columns
  belongs_to :question_row_column_type, inverse_of: :question_row_columns

  has_many :question_row_column_fields, dependent: :destroy, inverse_of: :question_row_column

  has_many :question_row_columns_question_row_column_options, dependent: :destroy, inverse_of: :question_row_column
  has_many :question_row_column_options, through: :question_row_columns_question_row_column_options, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  #accepts_nested_attributes_for :question_row_column_fields
  accepts_nested_attributes_for :question_row_columns_question_row_column_options, allow_destroy: true


  delegate :question,      to: :question_row
  delegate :question_type, to: :question_row

  def field_validation_value_for(name)
    question_row_columns_question_row_column_options
      .joins(:question_row_column_option)
      .find_by(question_row_column_options: { name: name })
      .name
  end

  private

    def associate_default_question_row_column_type
      self.question_row_column_type = QuestionRowColumnType.find_by(name: 'text')
      self.save
    end

    def create_default_question_row_column_options
      QuestionRowColumnOption.all.each do |opt|
        self.question_row_column_options << opt
      end
    end

    def create_default_question_row_column_field
      self.question_row_column_fields.create
    end

    def ensure_question_row_column_fields
      if self.question_row_column_type_id == 2  # Numeric requires 2 fields.
        self.question_row_column_fields.create if self.question_row_column_fields.length < 2
      end
    end
end
