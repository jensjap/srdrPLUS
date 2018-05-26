# Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1Row. This is meant to be Outcome Population.
class ExtractionsExtractionFormsProjectsSectionsType1Row < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  # We need to create the four ResultStatisticSections:
  #   - Descriptive Statistics
  #   - Between Arm Comparisons
  #   - Within Arm Comparisons
  #   - NET Change
  after_create :create_default_result_statistic_sections
  after_create :create_default_type1_row_columns

  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_type1_rows
  belongs_to :population_name,                                      inverse_of: :extractions_extraction_forms_projects_sections_type1_rows

  has_many :comparable_elements, as: :comparable

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1_row

  has_many :result_statistic_sections, dependent: :destroy, inverse_of: :population, foreign_key: 'population_id'

  delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1

  def descriptive_statistics_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 1)
  end

  def between_arm_comparisons_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 2)
  end

  def within_arm_comparisons_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 3)
  end

  def net_difference_comparisons_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 4)
  end

  private

    def create_default_result_statistic_sections
      result_statistic_sections.create!([
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Descriptive Statistics') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Between Arm Comparisons') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Within Arm Comparisons') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'NET Change') },
      ])
    end

    def create_default_type1_row_columns
      create_appropriate_number_of_type1_row_columns
    end

    def create_appropriate_number_of_type1_row_columns
      # Need to reload self.question here because it is being cached and its CollectionProxy
      # doesn't have the newly created extractions_extraction_forms_projects_sections_type1_row yet.
      self.extractions_extraction_forms_projects_sections_type1.reload if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.blank?

      if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count == 0

        # If this is the first/only row then we default to creating (arbitrarily) 1 column.
        self.extractions_extraction_forms_projects_sections_type1_row_columns.create(timepoint_name: TimepointName.first, is_baseline: true)

      else

        # Otherwise, create the same number of columns as other rows have.
        # I don't remember why we did -1 here.
        #(self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count - 1).times do |c|
        self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count.times do |c|
          self.extractions_extraction_forms_projects_sections_type1_row_columns.create
        end

      end
    end
end
