# == Schema Information
#
# Table name: comparisons_arms_rssms
#
#  id                                                      :integer          not null, primary key
#  comparison_id                                           :integer
#  extractions_extraction_forms_projects_sections_type1_id :integer
#  result_statistic_sections_measure_id                    :integer
#  deleted_at                                              :datetime
#  active                                                  :boolean
#  created_at                                              :datetime         not null
#  updated_at                                              :datetime         not null
#

class ComparisonsArmsRssm < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  # before_destroy :really_destroy_children!
  def really_destroy_children!
    Record.with_deleted.where(recordable_type: self.class, recordable_id: id).each(&:really_destroy!)
  end

  belongs_to :comparison
  belongs_to :extractions_extraction_forms_projects_sections_type1
  belongs_to :result_statistic_sections_measure

  has_many :records, as: :recordable

  delegate :extraction,                                    to: :extractions_extraction_forms_projects_sections_type1
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1
  delegate :result_statistic_section,                      to: :result_statistic_sections_measure

  def self.find_record_by_extraction
    'Mock Value'
  end

  def self.find_record(comparison, extractions_extraction_forms_projects_sections_type1, result_statistic_sections_measure)
    comparisons_arms_rssm = find_or_create_by!(comparison:,
                                               extractions_extraction_forms_projects_sections_type1:,
                                               result_statistic_sections_measure:)
    Record.find_or_create_by!(recordable: comparisons_arms_rssm)
  end
end
