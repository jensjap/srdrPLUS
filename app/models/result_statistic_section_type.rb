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
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    result_statistic_sections.with_deleted.each do |child|
      child.really_destroy!
    end
    result_statistic_section_types_measures.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  TYPE_NAMES = %w[Descriptive BAC WAC NET].freeze

  has_many :result_statistic_sections, dependent: :destroy, inverse_of: :result_statistic_section_type

  has_many :result_statistic_section_types_measures, dependent: :destroy, inverse_of: :result_statistic_section_type
  has_many :measures, through: :result_statistic_section_types_measures, dependent: :destroy

  def type_name
    TYPE_NAMES[id - 1]
  end
end
