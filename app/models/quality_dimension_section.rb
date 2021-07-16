# == Schema Information
#
# Table name: quality_dimension_sections
#
#  id                                 :integer          not null, primary key
#  name                               :string(255)
#  description                        :text(65535)
#  deleted_at                         :datetime
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  quality_dimension_section_group_id :bigint
#

class QualityDimensionSection < ApplicationRecord
  acts_as_paranoid

  belongs_to :quality_dimension_section_group, inverse_of: :quality_dimension_sections
  has_many :quality_dimension_questions, inverse_of: :quality_dimension_section
end
