# == Schema Information
#
# Table name: question_row_columns_question_row_column_options
#
#  id                            :integer          not null, primary key
#  question_row_column_id        :integer
#  question_row_column_option_id :integer
#  name                          :text(65535)
#  deleted_at                    :datetime
#  active                        :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class QuestionRowColumnsQuestionRowColumnOption < ApplicationRecord
  include SharedParanoiaMethods
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  after_create :set_default_values
  after_create :record_suggestor

  belongs_to :question_row_column,        inverse_of: :question_row_columns_question_row_column_options
  belongs_to :question_row_column_option, inverse_of: :question_row_columns_question_row_column_options

  has_one :suggestion, as: :suggestable, dependent: :destroy
  has_one :followup_field, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
    dependent: :destroy,
    inverse_of: :question_row_columns_question_row_column_option
  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields,
    through: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
    dependent: :destroy

  accepts_nested_attributes_for :question_row_column_option, allow_destroy: false

  delegate :question,                 to: :question_row_column
  delegate :question_row,             to: :question_row_column
  delegate :question_row_column_type, to: :question_row_column

  def includes_followup
    return self.followup_field.present?
  end

  def includes_followup=(val)
    if val and not self.followup_field.present?
      deleted_field = FollowupField.where(question_row_columns_question_row_column_option_id: self.id).only_deleted.first
      if deleted_field.present?
        deleted_field.restore :recursive => true
      else
        self.build_followup_field.save
    elsif not val and self.followup_field.present?
      self.followup_field.destroy.save
    end
  end

  private

  def set_default_values
    case self.question_row_column_option.name
    when 'answer_choice'
      self.name      ||= ''
    when 'min_length'
      self.name      ||= 0
    when 'max_length'
      self.name      ||= 255
    when 'additional_char'
      self.name      ||= false
    when 'min_value'
      self.name      ||= 0
    when 'max_value'
      self.name      ||= 255
    when 'coefficient'
      self.name      ||= 5
    when 'exponent'
      self.name      ||= 0
    else
      raise 'Unknown QuestionRowColumnOption'
    end

    self.save
  end
end
