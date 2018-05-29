class Comparison < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :result_statistic_section, inverse_of: :comparisons

  has_many :comparate_groups, dependent: :destroy, inverse_of: :comparison
  has_many :comparates, through: :comparate_groups, dependent: :destroy

  has_many :comparable_elements, as: :comparable

  has_many :comparisons_measures, dependent: :destroy, inverse_of: :comparison
  has_many :measurements, through: :comparisons_measures, dependent: :destroy
  has_many :measures, through: :comparisons_measures

  has_many :comparisons_arms_rssms, dependent: :destroy, inverse_of: :comparison
  has_many :tps_comparisons_rssms,  dependent: :destroy, inverse_of: :comparison
  has_many :wacs_bacs_rssms,        dependent: :destroy, foreign_key: 'wac_id'

  accepts_nested_attributes_for :comparate_groups, allow_destroy: true
  accepts_nested_attributes_for :comparisons_measures, allow_destroy: true
  accepts_nested_attributes_for :measurements, allow_destroy: true

  def tps_comparisons_rssms_values(eefpst1rc_id, rssm)
    recordables = tps_comparisons_rssms
      .where(
        timepoint_id: eefpst1rc_id,
        result_statistic_sections_measure: rssm)
    Record.where(recordable: recordables).pluck(:name)
  end

  def comparisons_arms_rssms_values(eefpst1_arm_id, rssm)
    recordables = comparisons_arms_rssms
      .where(
        extractions_extraction_forms_projects_sections_type1_id: eefpst1_arm_id,
        result_statistic_sections_measure: rssm)
    Record.where(recordable: recordables).pluck(:name)
  end

  def wacs_bacs_rssms_values(bac_id, rssm)
    recordables = wacs_bacs_rssms
      .where(
        bac_id: bac_id,
        result_statistic_sections_measure: rssm)
    Record.where(recordable: recordables).pluck(:name)
  end

  # This is meant to print out the comparison in pretty format.
  # Example:
  #   [arm1] vs [arm2]
  #   [arm1, arm2] vs [arm3]
  def pretty_print
  end
end
