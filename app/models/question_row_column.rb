# == Schema Information
#
# Table name: question_row_columns
#
#  id                          :integer          not null, primary key
#  question_row_id             :integer
#  question_row_column_type_id :integer
#  name                        :string(255)
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class QuestionRowColumn < ApplicationRecord
  attr_accessor :skip_callbacks

  after_create :create_default_question_row_column_options, unless: :skip_callbacks
  after_create :create_default_question_row_column_field, unless: :skip_callbacks

  after_save :ensure_question_row_column_fields, unless: :skip_callbacks

  belongs_to :question_row,             inverse_of: :question_row_columns
  belongs_to :question_row_column_type, inverse_of: :question_row_columns

  has_many :question_row_column_fields, dependent: :destroy, inverse_of: :question_row_column

  has_many :question_row_columns_question_row_column_options, dependent: :destroy, inverse_of: :question_row_column
  has_many :question_row_column_options, through: :question_row_columns_question_row_column_options, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  amoeba do
    enable
    customize(lambda { |_original, cloned|
      cloned.skip_callbacks = true
    })
  end

  # accepts_nested_attributes_for :question_row_column_fields
  accepts_nested_attributes_for :question_row_columns_question_row_column_options, allow_destroy: true

  delegate :question,      to: :question_row
  delegate :question_type, to: :question_row
  delegate :project, to: :question

  def field_validation_value_for(name)
    QuestionRowColumnsQuestionRowColumnOption
      .find_by!(
        question_row_column: self,
        question_row_column_option: QuestionRowColumnOption.find_by(name:)
      ).name
  end

  def extracted_data?
    question_row_column_fields.any? do |qrcf|
      qrcf.extractions_extraction_forms_projects_sections_question_row_column_fields.any? do |eefpsqrcf|
        eefpsqrcf.records.any? do |record|
          record.name.present?
        end
      end
    end
  end

  private

  def create_default_question_row_column_options
    QuestionRowColumnOption.all.each do |opt|
      question_row_columns_question_row_column_options.create(
        question_row_column: self,
        question_row_column_option: opt
      )
    end
  end

  def create_default_question_row_column_field
    question_row_column_fields.create unless question_row_column_fields.present?
  end

  def ensure_question_row_column_fields
    if question_row_column_type.name == QuestionRowColumnType::NUMERIC  # Numeric requires 2 fields.
      question_row_column_fields.create! while question_row_column_fields.length < 2
    end
  end
end
