class ExtractionsExtractionFormsProjectsSectionsType1 < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  scope :by_section_name_and_extraction_id_and_extraction_forms_project_id, -> (section_name, extraction_id, extraction_forms_project_id) {
    joins([:type1, extractions_extraction_forms_projects_section: [:extraction, { extraction_forms_projects_section: [:extraction_forms_project, :section] }]])
      .where(sections: { name: section_name })
      .where(extractions: { id: extraction_id })
      .where(extraction_forms_projects: { id: extraction_forms_project_id })
  }

  # Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1Row. This is meant to be Outcome Timepoint.
  after_create :create_default_type1_rows

  after_save :ensure_matrix_column_headers

  belongs_to :type1_type,                                    inverse_of: :extractions_extraction_forms_projects_sections_type1s, optional: true
  belongs_to :extractions_extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections_type1s
  belongs_to :type1,                                         inverse_of: :extractions_extraction_forms_projects_sections_type1s

  has_many :extractions_extraction_forms_projects_sections_type1_rows,                 dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1
  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1

  delegate :extraction, to: :extractions_extraction_forms_projects_section

  validates :type1_id, uniqueness: { scope: :extractions_extraction_forms_projects_section_id }

  def type1_name_and_description
    text =  "#{ type1.name }"
    text += " (#{ type1.description })" if type1.description.present?
    return text
  end

  private

    # Only create these for Outcomes.
    def create_default_type1_rows
      if self.extractions_extraction_forms_projects_section.extraction_forms_projects_section.section.name == 'Outcomes'
        self.extractions_extraction_forms_projects_sections_type1_rows.create(name: 'Timepoint 1', is_baseline: true)
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
