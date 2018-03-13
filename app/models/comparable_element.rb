class ComparableElement < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :comparable, polymorphic: true

  has_one :comparate
  #has_one :extractions_extraction_forms_projects_sections_type1s, :source => :comparable, :source_type => 'ExtractionsExtractionFormsProjectsSectionsType1'
end
