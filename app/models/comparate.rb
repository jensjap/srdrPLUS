# == Schema Information
#
# Table name: comparates
#
#  id                    :integer          not null, primary key
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  comparate_group_id    :integer
#  comparable_element_id :integer
#

class Comparate < ApplicationRecord
  attr_accessor :is_amoeba_copy

  amoeba do
    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  after_commit :set_extraction_stale, on: %i[create update destroy]

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :comparate_group,    inverse_of: :comparates
  belongs_to :comparable_element, inverse_of: :comparates

  accepts_nested_attributes_for :comparable_element, allow_destroy: true

  private

  def set_extraction_stale
    comparate_group&.comparison&.comparisons_result_statistic_sections&.each do |crss|
      if crss.result_statistic_section.population.extraction&.extraction_checksum&.present?
        crss.result_statistic_section.population.extraction.extraction_checksum.update(is_stale: true)
      end
    end
  end

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
