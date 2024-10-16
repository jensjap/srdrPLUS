# == Schema Information
#
# Table name: question_row_column_fields
#
#  id                           :integer          not null, primary key
#  question_row_column_id       :integer
#  name                         :string(255)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  question_row_column_field_id :integer
#

class QuestionRowColumnField < ApplicationRecord
  # after_create :create_default_question_row_column_fields_question_row_column_field_options

  belongs_to :question_row_column, inverse_of: :question_row_column_fields

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy,
                                                                                       inverse_of: :question_row_column_field
  has_many :extractions_extraction_forms_projects_sections,
           through: :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  # has_many :question_row_column_fields_question_row_column_field_options, dependent: :destroy, inverse_of: :question_row_column_field
  # has_many :question_row_column_field_options, through: :question_row_column_fields_question_row_column_field_options, dependent: :destroy

  delegate :question_type, to: :question_row_column
  delegate :question,      to: :question_row_column

  # def create_default_question_row_column_fields_question_row_column_field_options
  #  # Might create a placeholder record here depending on the QuestionRowColumnType??
  # end
end
