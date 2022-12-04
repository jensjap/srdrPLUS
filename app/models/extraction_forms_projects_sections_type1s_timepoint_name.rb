# == Schema Information
#
# Table name: extraction_forms_projects_sections_type1s_timepoint_names
#
#  id                                          :integer          not null, primary key
#  extraction_forms_projects_sections_type1_id :integer
#  timepoint_name_id                           :integer
#  deleted_at                                  :datetime
#  active                                      :boolean
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#

class ExtractionFormsProjectsSectionsType1sTimepointName < ApplicationRecord
  belongs_to :extraction_forms_projects_sections_type1
  belongs_to :timepoint_name
end
