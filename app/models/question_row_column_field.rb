class QuestionRowColumnField < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :associate_default_question_row_column_field_type
  after_create :create_default_question_row_column_fields_question_row_column_field_options

  belongs_to :question_row_column,            inverse_of: :question_row_column_field
  belongs_to :question_row_column_field_type, inverse_of: :question_row_column_fields

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy, inverse_of: :question_row_column_field
  has_many :extractions_extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy
  has_many :records, as: :recordable

  has_many :question_row_column_fields_question_row_column_field_options, dependent: :destroy, inverse_of: :question_row_column_field
  has_many :question_row_column_field_options, through: :question_row_column_fields_question_row_column_field_options, dependent: :destroy

  accepts_nested_attributes_for :question_row_column_field_options, allow_destroy: true
  accepts_nested_attributes_for :question_row_column_fields_question_row_column_field_options, allow_destroy: true

  delegate :question_type, to: :question_row_column
  delegate :question, to: :question_row_column

  private

  def associate_default_question_row_column_field_type
    self.question_row_column_field_type = QuestionRowColumnFieldType.find_by(name: 'text')
    self.save
  end

  def create_default_question_row_column_fields_question_row_column_field_options
    self.question_row_column_field_options << QuestionRowColumnFieldOption.find_by(name: 'answer_choice')
    self.question_row_column_field_options << QuestionRowColumnFieldOption.find_by(name: 'min_length')
    self.question_row_column_field_options << QuestionRowColumnFieldOption.find_by(name: 'max_length')
    self.question_row_column_field_options << QuestionRowColumnFieldOption.find_by(name: 'min_value')
    self.question_row_column_field_options << QuestionRowColumnFieldOption.find_by(name: 'max_value')
    self.question_row_column_field_options << QuestionRowColumnFieldOption.find_by(name: 'coefficient')
    self.question_row_column_field_options << QuestionRowColumnFieldOption.find_by(name: 'exponent')
  end
end
