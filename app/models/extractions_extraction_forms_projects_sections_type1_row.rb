class ExtractionsExtractionFormsProjectsSectionsType1Row < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  # Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1RowColumn. This is meant to be Outcome Timepoint.
  after_create :create_default_row_columns

  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_type1_rows

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1_row

  private

    def create_default_row_columns
      self.extractions_extraction_forms_projects_sections_type1_row_columns.create(name: 'Baseline', is_baseline: true)
    end
end
