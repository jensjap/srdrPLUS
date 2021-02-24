# == Schema Information
#
# Table name: type1_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Type1Type < ApplicationRecord
  CATEGORICAL   = "Categorical".freeze
  CONTINUOUS    = "Continuous".freeze
  TIME_TO_EVENT = "Time to Event".freeze
  ADVERSE_EVENT = "Adverse Event".freeze
  INDEX_TEST    = "Index Test".freeze
  REFERENCE_TEST = "Reference Test".freeze

  scope :outcome_types, -> { where("name in (?)", ['Categorical', 'Continuous']) }
  scope :diagnostic_test_types, -> { where("name in (?)", ['Index Test', 'Reference Test']) }

  has_many :extraction_forms_projects_sections_type1s,             inverse_of: :type1_type
  has_many :extractions_extraction_forms_projects_sections_type1s, inverse_of: :type1_type
  has_many :result_statistic_sections_measures,                    inverse_of: :type1_type
  has_many :result_statistic_section_types_measures,               inverse_of: :type1_type
end
