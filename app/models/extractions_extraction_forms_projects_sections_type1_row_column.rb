# Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1RowColumn. This is meant to be Outcome Timepoint.
class ExtractionsExtractionFormsProjectsSectionsType1RowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_save :ensure_only_one_baseline

  belongs_to :extractions_extraction_forms_projects_sections_type1_row, inverse_of: :extractions_extraction_forms_projects_sections_type1_row_columns
  belongs_to :timepoint_name,                                           inverse_of: :extractions_extraction_forms_projects_sections_type1_row_columns

  delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1_row

  def label_with_baseline_indicator
    text = "#{ timepoint_name.name }"
    text += " #{ timepoint_name.unit }" if timepoint_name.unit.present?
    text += " (Baseline)" if is_baseline
    return text
  end

  private

    def ensure_only_one_baseline
      return false unless extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.section.name == 'Outcomes'
      if is_baseline
        extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
          tp.update_attribute(:is_baseline, false) unless tp == self
        end
      end
    end
end
