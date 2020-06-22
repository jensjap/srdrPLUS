# == Schema Information
#
# Table name: extraction_forms_projects_sections_type1_rows
#
#  id                                          :bigint           not null, primary key
#  extraction_forms_projects_sections_type1_id :bigint
#  population_name_id                          :bigint
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#

class ExtractionFormsProjectsSectionsType1Row < ApplicationRecord
  belongs_to :extraction_forms_projects_sections_type1
  belongs_to :population_name

  accepts_nested_attributes_for :population_name, reject_if: :all_blank
end
