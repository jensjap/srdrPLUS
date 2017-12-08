class ExtractionsExtractionFormsProjectsSectionsType1RowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  # We need to create the four ResultStatisticSections:
  #   - Descriptive Statistics
  #   - Between Arm Comparisons
  #   - Within Arm Comparisons
  #   - NET Change
  after_create :create_default_result_statistic_sections

  belongs_to :extractions_extraction_forms_projects_sections_type1_row, inverse_of: :extractions_extraction_forms_projects_sections_type1_row_columns

  has_many :result_statistic_sections, dependent: :destroy, inverse_of: :subgroup, foreign_key: 'subgroup_id'

  private

    def create_default_result_statistic_sections
      result_statistic_sections.create!([
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Descriptive Statistics') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Between Arm Comparisons') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Within Arm Comparisons') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'NET Change') },
      ])
    end
end
