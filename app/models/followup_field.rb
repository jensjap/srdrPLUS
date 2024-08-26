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
  attr_accessor :is_amoeba_copy

  amoeba do
    customize(lambda { |original, copy|
      copy.is_amoeba_copy = true
      copy.amoeba_source_object = original
    })
  end

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :question_row_columns_question_row_column_option,
             inverse_of: :followup_field
  belongs_to :amoeba_source_object,
             class_name: 'FollowupField',
             foreign_key: 'followup_field_id',
             optional: true

  has_many :amoeba_copies,
           class_name: 'FollowupField',
           foreign_key: 'followup_field_id',
           dependent: :nullify
  has_many :extractions_extraction_forms_projects_sections_followup_fields,
           dependent: :destroy,
           inverse_of: :followup_field
  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  delegate :project, to: :question_row_columns_question_row_column_option

  private

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
