# == Schema Information
#
# Table name: comparisons
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  is_anova   :boolean          default(FALSE), not null
#

class Comparison < ApplicationRecord
  has_many :comparate_groups, inverse_of: :comparison, dependent: :destroy
  has_many :comparates, through: :comparate_groups, dependent: :destroy

  has_many :comparable_elements, as: :comparable, dependent: :destroy

  has_many :comparisons_measures, dependent: :destroy, inverse_of: :comparison
  has_many :measures,     through: :comparisons_measures

  has_many :comparisons_arms_rssms, dependent: :destroy, inverse_of: :comparison
  has_many :tps_comparisons_rssms,  dependent: :destroy, inverse_of: :comparison
  has_many :wacs_bacs_rssms,        dependent: :destroy, foreign_key: 'wac_id'

  has_many :comparisons_result_statistic_sections, dependent: :destroy, inverse_of: :comparison
  has_many :result_statistic_sections, through: :comparisons_result_statistic_sections, dependent: :destroy

  accepts_nested_attributes_for :comparate_groups,     allow_destroy: true
  accepts_nested_attributes_for :comparisons_measures, allow_destroy: true

  # Fetch records for this particular comparison
  # by timepoint, bac, and measure.
  def tps_comparisons_rssms_values(eefpst1rc_id, rssm)
    recordables = tps_comparisons_rssms
                  .where(
                    timepoint_id: eefpst1rc_id,
                    result_statistic_sections_measure: rssm
                  )
    Record.where(recordable: recordables.first).first.try(:name).to_s.gsub(/\P{Print}|\p{Cf}/, '')
  end

  # Fetch records for this particular comparison
  # by wac, arm, and measure.
  def comparisons_arms_rssms_values(eefpst1_arm_id, rssm)
    recordables = comparisons_arms_rssms
                  .where(
                    extractions_extraction_forms_projects_sections_type1_id: eefpst1_arm_id,
                    result_statistic_sections_measure: rssm
                  )
    Record.where(recordable: recordables.first).first.try(:name).to_s.gsub(/\P{Print}|\p{Cf}/, '')
  end

  # Fetch records for this particular comparison
  # by wac, bac, and measure.
  def wacs_bacs_rssms_values(bac_id, rssm)
    recordables = wacs_bacs_rssms
                  .where(
                    bac_id:,
                    result_statistic_sections_measure: rssm
                  )
    Record.where(recordable: recordables.first).first.try(:name).to_s.gsub(/\P{Print}|\p{Cf}/, '')
  end

  # This is meant to print out the comparison in pretty format.
  # Example:
  #   [arm1] vs [arm2]
  #   [arm1, arm2] vs [arm3]
  def pretty_print_export_header
    text = ''
    comparate_groups.each do |cg|
      text += '['
      cg.comparates.each do |c|
        comparable = c.comparable_element.comparable
        if comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1
          t1 = comparable.type1
          text += t1.name
          text += " (#{t1.description}), " if t1.description.present?
        elsif comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1RowColumn
          tn = comparable.timepoint_name
          text += tn.name
          text += " (#{tn.unit}), " if tn.unit.present?
        end
      end
      text = text.gsub(/,\s$/, '') + ']'
      text += ' vs. '
    end

    "[ID: #{id}] " + text[0..-6]
  end

  def tokenize
    text = ''
    comparate_groups.each do |cg|
      text += '['
      cg.comparates.each do |c|
        comparable = c.comparable_element.comparable
        if comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1
          text += 't1-'
          text += comparable.type1.id.to_s
          text += ', '
        elsif comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1RowColumn
          text += 'tp-'
          text += comparable.timepoint_name.id.to_s
          text += ', '
        end
      end
      text = text.gsub(/,\s$/, '') + ']'
      text += ' vs. '
    end

    text[0..-6]
  end
end
