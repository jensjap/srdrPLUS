class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField < ApplicationRecord
  include SharedParanoiaMethods

  self.table_name = 'eefps_qrcf'

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields, optional: true
  belongs_to :extractions_extraction_forms_projects_section,        inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields
  belongs_to :question_row_column_field,                            inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields
end
