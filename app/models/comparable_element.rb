class ComparableElement < ApplicationRecord
  belongs_to :comparable, polymorphic: true
  has_many :extractions_extraction_forms_projects_sections_type1s, :source => :comparable, :source_type => 'ExtractionsExtractionFormsProjectsSectionsType1'
end
