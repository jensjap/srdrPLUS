class ResultStatisticSection < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :result_statistic_section_type,                                                    inverse_of: :result_statistic_sections
  belongs_to :subgroup, class_name: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn', inverse_of: :result_statistic_sections
end
