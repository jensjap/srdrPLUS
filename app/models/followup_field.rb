# == Schema Information
#
# Table name: followup_fields
#
#  id                                                 :bigint           not null, primary key
#  question_row_columns_question_row_column_option_id :bigint
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#
class FollowupField < ApplicationRecord
  belongs_to :question_row_columns_question_row_column_option, inverse_of: :followup_field

  has_many :extractions_extraction_forms_projects_sections_followup_fields, dependent: :destroy,
                                                                            inverse_of: :followup_field
  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  delegate :project, to: :question_row_columns_question_row_column_option
end
