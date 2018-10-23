class ComparableElement < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

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
