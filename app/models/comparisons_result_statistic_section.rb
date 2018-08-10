class ComparisonsResultStatisticSection < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :comparison
  belongs_to :result_statistic_section

  validate :prevent_duplicate_comparate_groups#, :ensure_comparison_size

  def prevent_duplicate_comparate_groups
    comparison.comparate_groups.to_a.combination(2) do |cg1, cg2|
      if cg1.eql?(cg2)
        errors.add(:base, :duplicate, message: 'Invalid comparison. Do not compare identical elements.')
      end
    end
  end

  def ensure_comparison_size
    if comparison.comparate_groups.map.to_set.length < 2
      errors.add(:size, 'Invalid comparison. A comparison must compare at least 2 things.')
    end
  end
end
