# == Schema Information
#
# Table name: question_row_columns_question_row_column_options
#
#  id                            :integer          not null, primary key
#  question_row_column_id        :integer
#  question_row_column_option_id :integer
#  name                          :text(65535)
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#

class QuestionRowColumnsQuestionRowColumnOption < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  attr_accessor :is_amoeba_copy

  default_scope { order(:pos, :id) }

  amoeba do
    include_association :followup_field

    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  after_create :set_default_values
  after_create :record_suggestor

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :question_row_column,        inverse_of: :question_row_columns_question_row_column_options
  belongs_to :question_row_column_option, inverse_of: :question_row_columns_question_row_column_options

  has_one :suggestion, as: :suggestable, dependent: :destroy
  has_one :followup_field, dependent: :destroy

  has_many :dependencies, as: :prerequisitable, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
           dependent: :destroy,
           inverse_of: :question_row_columns_question_row_column_option
  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields,
           through: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options

  accepts_nested_attributes_for :question_row_column_option, allow_destroy: false

  delegate :question,                 to: :question_row_column
  delegate :question_row,             to: :question_row_column
  delegate :question_row_column_type, to: :question_row_column
  delegate :project, to: :question

  def includes_followup
    followup_field.present?
  end

  def includes_followup=(bool)
    bool = ActiveModel::Type::Boolean.new.cast bool
    if bool && !followup_field.present?
      build_followup_field.save
    elsif !bool && followup_field.present?
      followup_field.destroy.save
    end
  end

  private

  def set_default_values
    case question_row_column_option.name
    when 'answer_choice'
      self.name      ||= ''
    when 'min_length'
      self.name      ||= 0
    when 'max_length'
      self.name      ||= ''
    when 'additional_char'
      self.name      ||= false
    when 'min_value'
      self.name      ||= ''
    when 'max_value'
      self.name      ||= ''
    when 'coefficient'
      self.name      ||= 5
    when 'exponent'
      self.name      ||= 0
    else
      raise 'Unknown QuestionRowColumnOption'
    end

    save
  end

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
