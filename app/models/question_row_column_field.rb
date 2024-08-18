# == Schema Information
#
# Table name: question_row_column_fields
#
#  id                     :integer          not null, primary key
#  question_row_column_id :integer
#  name                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class QuestionRowColumnField < ApplicationRecord
  attr_accessor :is_amoeba_copy

  amoeba do
    customize(lambda { |_, cloned|
      cloned.is_amoeba_copy = true
    })
  end

  before_commit :correct_parent_associations

  belongs_to :question_row_column, inverse_of: :question_row_column_fields

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy,
                                                                                       inverse_of: :question_row_column_field
  has_many :extractions_extraction_forms_projects_sections,
           through: :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  delegate :question_type, to: :question_row_column
  delegate :question,      to: :question_row_column

  private

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
