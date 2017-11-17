class ExtractionsExtractionFormsProjectsSectionsType1 < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  scope :outcomes, -> (extraction_id, extraction_forms_project_id) {
    joins(extractions_extraction_forms_projects_section: [:extraction, { extraction_forms_projects_section: [:extraction_forms_project, :section] }])
      .where(extractions: { id: extraction_id })
      .where(extraction_forms_projects: { id: extraction_forms_project_id })
      .where(sections: { name: 'Outcomes' })
  }

  scope :arms,     -> (extraction_id, extraction_forms_project_id) {
    joins(extractions_extraction_forms_projects_section: [:extraction, { extraction_forms_projects_section: [:extraction_forms_project, :section] }])
      .where(extractions: { id: extraction_id })
      .where(extraction_forms_projects: { id: extraction_forms_project_id })
      .where(sections: { name: 'Arms' })
  }

  # Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1Row. This is meant to be Outcome Timepoint.
  after_create :create_default_type1_rows

  after_save :ensure_matrix_column_headers

  belongs_to :type1_type,                                    inverse_of: :extractions_extraction_forms_projects_sections_type1s, optional: true
  belongs_to :extractions_extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections_type1s
  belongs_to :type1,                                         inverse_of: :extractions_extraction_forms_projects_sections_type1s

  has_many :extractions_extraction_forms_projects_sections_type1_rows, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1

  private

    # Only create these for Outcomes.
    def create_default_type1_rows
      if self.extractions_extraction_forms_projects_section.extraction_forms_projects_section.section.name == 'Outcomes'
        self.extractions_extraction_forms_projects_sections_type1_rows.create(name: 'Baseline', is_baseline: true)
      end
    end

    def ensure_matrix_column_headers
      if self.extractions_extraction_forms_projects_section.extraction_forms_projects_section.section.name == 'Outcomes'
        first_row = self.extractions_extraction_forms_projects_sections_type1_rows.first
        rest_rows = self.extractions_extraction_forms_projects_sections_type1_rows[1..-1]

        column_headers = []

        first_row.extractions_extraction_forms_projects_sections_type1_row_columns.each do |c|
          column_headers << c.name
        end

        rest_rows.each do |r|
          r.extractions_extraction_forms_projects_sections_type1_row_columns.each_with_index do |rc, idx|
            rc.update(name: column_headers[idx])
          end
        end
      end
    end
end
