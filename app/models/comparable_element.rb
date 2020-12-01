# == Schema Information
#
# Table name: comparable_elements
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  comparable_type :string(255)
#  comparable_id   :integer
#  deleted_at      :datetime
#

class ComparableElement < ApplicationRecord
  acts_as_paranoid

  after_destroy :destroy_comparisons

  belongs_to :comparable, polymorphic: true

  has_many :comparates, inverse_of: :comparable_element
  has_many :comparate_groups, through: :comparates
  has_many :comparisons, through: :comparate_groups
  #!!! Birol: why is this has_one?
  #has_one :comparate
  #has_one :extractions_extraction_forms_projects_sections_type1s, :source => :comparable, :source_type => 'ExtractionsExtractionFormsProjectsSectionsType1'

  private

    def destroy_comparisons
      self.comparisons.each(&:destroy)
    end
end
