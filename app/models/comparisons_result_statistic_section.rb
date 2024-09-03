# == Schema Information
#
# Table name: comparisons_result_statistic_sections
#
#  id                          :integer          not null, primary key
#  comparison_id               :integer
#  result_statistic_section_id :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class ComparisonsResultStatisticSection < ApplicationRecord
  attr_accessor :is_amoeba_copy

  amoeba do
    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :comparison
  belongs_to :result_statistic_section

  validate :validate_comparison_checks

  private

  def validate_comparison_checks
    check_invalid_comparate_group_size
    check_duplicates_within_comparison
    check_comparate_group_duplicates_across_comparisons
    check_anova_duplicates_across_comparisons
  end

  def check_invalid_comparate_group_size
    return if comparison.is_anova
    return if comparison.comparate_groups.size == 2

    add_error_message(%i[base invalid_size], 'Comparison must have two comparison groups.')
  end

  def check_duplicates_within_comparison
    return if comparison.is_anova
    return unless comparison.comparate_groups.any? do |comparate_group|
      comparate_group.comparable_elements.map(&:comparable).uniq.size !=
      comparate_group.comparable_elements.map(&:comparable).size
    end

    add_error_message(%i[base duplicate], 'Duplicate comparable elements within the same group.')
  end

  def check_comparate_group_duplicates_across_comparisons
    return if comparison.is_anova

    new_comparate_groups = [comparison.comparate_groups[0].comparable_elements.map(&:comparable).sort,
                            comparison.comparate_groups[1].comparable_elements.map(&:comparable).sort].sort
    result_statistic_section.comparisons.each do |comparison|
      next if comparison.is_anova

      current_comparate_groups = [comparison.comparate_groups[0].comparable_elements.map(&:comparable).sort,
                                  comparison.comparate_groups[1].comparable_elements.map(&:comparable).sort].sort
      next unless new_comparate_groups == current_comparate_groups

      add_error_message(%i[base duplicate], 'Duplicate comparison groups.')
    end
  end

  def check_anova_duplicates_across_comparisons
    return unless comparison.is_anova
    return unless result_statistic_section.comparisons.any?(&:is_anova)

    add_error_message(%i[base duplicate], 'Cannot have more than one anova comparison.')
  end

  def add_error_message(error_arguments, message)
    errors.add(*error_arguments, message:)
    result_statistic_section.errors.add(*error_arguments, message:)
  end

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
