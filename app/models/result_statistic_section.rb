class ResultStatisticSection < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_descriptive_statistics

  belongs_to :result_statistic_section_type,                                                inverse_of: :result_statistic_sections
  belongs_to :population, class_name: 'ExtractionsExtractionFormsProjectsSectionsType1Row', inverse_of: :result_statistic_sections

  has_many :result_statistic_sections_measures, dependent: :destroy, inverse_of: :result_statistic_section
  has_many :measures, through: :result_statistic_sections_measures, dependent: :destroy

  has_many :comparisons, dependent: :destroy, inverse_of: :result_statistic_section
  has_many :comparate_groups, through: :comparisons, dependent: :destroy

  has_many :comparates, through: :comparate_groups, dependent: :destroy
  has_many :comparable_elements, through: :comparates, dependent: :destroy
  has_many :comparables, through: :comparable_elements, dependent: :destroy
  has_many :comparisons_measures, through: :comparables, dependent: :destroy
  has_many :measurements, through: :comparisons_measures, dependent: :destroy

  accepts_nested_attributes_for :comparisons, allow_destroy: true
  accepts_nested_attributes_for :comparate_groups, allow_destroy: true
  accepts_nested_attributes_for :comparates, allow_destroy: true
  accepts_nested_attributes_for :comparable_elements, allow_destroy: true
  accepts_nested_attributes_for :comparisons_measures, allow_destroy: true
  accepts_nested_attributes_for :measurements, allow_destroy: true

  delegate :extraction, to: :population

  def timepoints
    population.extractions_extraction_forms_projects_sections_type1_row_columns
  end

  def result_section
    population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction.extractions_extraction_forms_projects_sections.last
  end

  private
    def create_default_descriptive_statistics
      Measure.result_statistic_section_type_defaults(self.result_statistic_section_type.id).each do |m|
        self.result_statistic_sections_measures.create(measure: m)
        #!!!: This might work now. Previously ResultStatisticSection was child of ExtractionsExtractionFormsProjectsSectionsType1RowColumn
        #     instead of ExtractionsExtractionFormsProjectsSectionsType1Row.
        #measures << m
      end
    end
end
