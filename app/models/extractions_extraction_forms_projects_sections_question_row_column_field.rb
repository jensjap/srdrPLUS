# == Schema Information
#
# Table name: eefps_qrcfs
#
#  id                                                      :integer          not null, primary key
#  extractions_extraction_forms_projects_sections_type1_id :integer
#  extractions_extraction_forms_projects_section_id        :integer
#  question_row_column_field_id                            :integer
#  name                                                    :text(65535)
#  deleted_at                                              :datetime
#  active                                                  :boolean
#  created_at                                              :datetime         not null
#  updated_at                                              :datetime         not null
#

class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField < ApplicationRecord
  include SharedParanoiaMethods
  include SharedProcessTokenMethods

  self.table_name = 'eefps_qrcfs'

  acts_as_paranoid column: :active, sentinel_value: true
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    Record.with_deleted.where(recordable_type: self.class, recordable_id: id).each(&:really_destroy!)
  end

  belongs_to :extractions_extraction_forms_projects_sections_type1,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields, optional: true
  belongs_to :extractions_extraction_forms_projects_section,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields
  belongs_to :question_row_column_field,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
           dependent: :destroy,
           inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_field,
           foreign_key: 'eefps_qrcf_id'
  has_many :question_row_columns_question_row_column_options,
           through: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
           dependent: :destroy

  has_many :records, as: :recordable

  # delegate :extraction, to: :extractions_extraction_forms_projects_section, allow_nil: true

  def extraction
    ExtractionsExtractionFormsProjectsSection.with_deleted.find_by(id: extractions_extraction_forms_projects_section_id).try(:extraction)
  end

  delegate :project, to: :extractions_extraction_forms_projects_section

  def question_row_columns_question_row_column_option_ids=(tokens)
    tokens.map do |token|
      resource = question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
      save_resource_name_with_token(resource, token)
    end
    super
  end
end
