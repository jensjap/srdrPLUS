# == Schema Information
#
# Table name: followup_fields
#
#  id                                                 :bigint           not null, primary key
#  question_row_columns_question_row_column_option_id :bigint
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  deleted_at                                         :datetime
#
class FollowupField < ApplicationRecord
  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    extractions_extraction_forms_projects_sections_followup_fields.with_deleted.each do |child|
      child.really_destroy!
    end
    Dependency.with_deleted.where(prerequisitable_type: self.class, prerequisitable_id: id).each(&:really_destroy!)
  end

  belongs_to :question_row_columns_question_row_column_option, inverse_of: :followup_field

  has_many :extractions_extraction_forms_projects_sections_followup_fields, dependent: :destroy,
                                                                            inverse_of: :followup_field
  has_many :dependencies, as: :prerequisitable, dependent: :destroy
end
