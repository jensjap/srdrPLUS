class ResultStatisticSection < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :create_default_descriptive_statistics

  belongs_to :result_statistic_section_type,                                                    inverse_of: :result_statistic_sections
  belongs_to :subgroup, class_name: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn', inverse_of: :result_statistic_sections

  has_many :result_statistic_sections_measures, dependent: :destroy, inverse_of: :result_statistic_section
  has_many :measures, through: :result_statistic_sections_measures, dependent: :destroy

  private

    def create_default_descriptive_statistics
      if result_statistic_section_type == ResultStatisticSectionType.find_by(name: 'Descriptive Statistics')
        Measure.is_default.each do |m|

          # This ends up adding m twice to ResultStatisticSection.
          #measures << m

          # This one works correctly...only adds it once.
          result_statistic_sections_measures.create(measure: m)
        end
      end
    end
end
