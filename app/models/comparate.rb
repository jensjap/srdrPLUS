class Comparate < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_commit :set_extraction_stale, on: [:create, :update, :destroy]

  belongs_to :comparate_group,    inverse_of: :comparates
  belongs_to :comparable_element, inverse_of: :comparates, dependent: :destroy

  accepts_nested_attributes_for :comparable_element, allow_destroy: true

  private

    def set_extraction_stale
      self.comparate_group.comparison.comparisons_result_statistic_sections.each do |crss|
        crss.result_statistic_section.population.extraction.extraction_checksum.update( is_stale: true ) 
      end
    end
end
