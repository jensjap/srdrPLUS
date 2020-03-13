# == Schema Information
#
# Table name: result_statistic_sections
#
#  id                               :integer          not null, primary key
#  result_statistic_section_type_id :integer
#  population_id                    :integer
#  deleted_at                       :datetime
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#

class ResultStatisticSection < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_measures

  belongs_to :result_statistic_section_type,                                                inverse_of: :result_statistic_sections
  belongs_to :population, class_name: 'ExtractionsExtractionFormsProjectsSectionsType1Row', inverse_of: :result_statistic_sections

  has_many :result_statistic_sections_measures, -> { joins(:measure).order('measures.id ASC') }, dependent: :destroy, inverse_of: :result_statistic_section
  has_many :measures, through: :result_statistic_sections_measures, dependent: :destroy

  has_many :comparisons_result_statistic_sections, dependent: :destroy, inverse_of: :result_statistic_section
  has_many :comparisons,          through: :comparisons_result_statistic_sections, dependent: :destroy
  has_many :comparate_groups,     through: :comparisons,                           dependent: :destroy
  has_many :comparates,           through: :comparate_groups,                      dependent: :destroy
  has_many :comparable_elements,  through: :comparates,                            dependent: :destroy
  has_many :comparables,          through: :comparable_elements,                   dependent: :destroy, source_type: 'ComparableElement'
  has_many :comparisons_measures, through: :comparables,                           dependent: :destroy, source: :comparates
  #remove this, we use records for all data collection
  has_many :measurements,         through: :comparisons_measures,                  dependent: :destroy, source: :comparable_element

  #remove this as well?
  accepts_nested_attributes_for :comparisons_result_statistic_sections, allow_destroy: true
  accepts_nested_attributes_for :comparisons,                           allow_destroy: false
  accepts_nested_attributes_for :comparate_groups,                      allow_destroy: false
  accepts_nested_attributes_for :comparates,                            allow_destroy: false
  accepts_nested_attributes_for :comparable_elements,                   allow_destroy: false
  #accepts_nested_attributes_for :comparables,                           allow_destroy: false  #!!! Do we need this?
  accepts_nested_attributes_for :comparisons_measures,                  allow_destroy: false
  accepts_nested_attributes_for :measurements,                          allow_destroy: false

  delegate :extraction, to: :population
  delegate :project, to: :extraction

  def timepoints
    population.extractions_extraction_forms_projects_sections_type1_row_columns
  end

  # Making the assumption that the result section is always last.
  def eefps_result
    population
      .extractions_extraction_forms_projects_sections_type1
      .extractions_extraction_forms_projects_section
      .extraction_forms_projects_section
      .extraction_forms_project
      .extraction_forms_projects_sections.last
  end

  private

    def create_default_measures
      #Measure.result_statistic_section_type_defaults(self.result_statistic_section_type.id).each do |m|
      #  self.result_statistic_sections_measures.create(measure: m)
      #  #!!!: This might work now. Previously ResultStatisticSection was child of ExtractionsExtractionFormsProjectsSectionsType1RowColumn
      #  #     instead of ExtractionsExtractionFormsProjectsSectionsType1Row.
      #  #measures << m
      #end

      ResultStatisticSectionTypesMeasure.where(
        result_statistic_section_type: result_statistic_section_type,
        type1_type: population.extractions_extraction_forms_projects_sections_type1.type1_type,
        default: true
      ).each do |rsstm|
        self.result_statistic_sections_measures.create(measure: rsstm.measure)
        rsstm.dependent_measures.each do |dm|
          self.result_statistic_sections_measures.create(measure: dm.measure)
        end
      end
    end
end
