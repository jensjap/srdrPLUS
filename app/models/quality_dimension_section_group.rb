# == Schema Information
#
# Table name: quality_dimension_section_groups
#
#  id         :bigint           not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  active     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class QualityDimensionSectionGroup < ApplicationRecord
  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    quality_dimension_sections.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  has_many :quality_dimension_sections, inverse_of: :quality_dimension_section_group
end
