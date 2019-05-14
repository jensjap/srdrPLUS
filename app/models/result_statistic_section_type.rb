# == Schema Information
#
# Table name: result_statistic_section_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ResultStatisticSectionType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :result_statistic_sections, dependent: :destroy, inverse_of: :result_statistic_section_type

  has_many :result_statistic_section_types_measures, dependent: :destroy, inverse_of: :result_statistic_section_type
  has_many :measures, through: :result_statistic_section_types_measures, dependent: :destroy
end
