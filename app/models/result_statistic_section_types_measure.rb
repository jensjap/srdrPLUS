# == Schema Information
#
# Table name: result_statistic_section_types_measures
#
#  id                                        :integer          not null, primary key
#  result_statistic_section_type_id          :integer
#  measure_id                                :integer
#  deleted_at                                :datetime
#  active                                    :boolean
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  default                                   :boolean          default(FALSE)
#  type1_type_id                             :integer
#  result_statistic_section_types_measure_id :integer
#

# These are the measures that should appear for each result_statistic_section.
class ResultStatisticSectionTypesMeasure < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  before_destroy :really_destroy_children!
  def really_destroy_children!
    dependent_measures.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  belongs_to :result_statistic_section_type, inverse_of: :result_statistic_section_types_measures
  belongs_to :measure,                       inverse_of: :result_statistic_section_types_measures
  belongs_to :type1_type,                    inverse_of: :result_statistic_section_types_measures, optional: true
  belongs_to :provider_measure,
             class_name: 'ResultStatisticSectionTypesMeasure',
             foreign_key: 'result_statistic_section_types_measure_id',
             optional: true

  has_many :dependent_measures,
           class_name: 'ResultStatisticSectionTypesMeasure',
           foreign_key: 'result_statistic_section_types_measure_id'
end
