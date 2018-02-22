class ComparateGroup < ApplicationRecord
  belongs_to :comparison
  has_many :comparates
  has_many :comparable_elements, through: :comparates
  has_many :extractions_extraction_forms_projects_sections_type1s, :through => :comparable_elements
end
