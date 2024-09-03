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
  after_commit :set_extraction_stale, on: %i[create update destroy]

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
end
