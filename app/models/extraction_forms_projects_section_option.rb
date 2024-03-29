# == Schema Information
#
# Table name: extraction_forms_projects_section_options
#
#  id                                   :integer          not null, primary key
#  extraction_forms_projects_section_id :integer
#  by_type1                             :boolean
#  include_total                        :boolean
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class ExtractionFormsProjectsSectionOption < ApplicationRecord
  belongs_to :extraction_forms_projects_section, inverse_of: :extraction_forms_projects_section_option
end
