# == Schema Information
#
# Table name: timepoint_names
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  unit       :string(255)      default(""), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TimepointName < ApplicationRecord
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :timepoint_name

  has_many :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy, inverse_of: :timepoint_name
  has_many :extraction_forms_projects_sections_type1s, through: :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy

  validates :unit, uniqueness: { scope: :name }

  # Written in one line.
  def pretty_print_export_header
    text  = name
    text += " (#{ unit })" if unit.present?
    return text
  end

  private

    def select_label
      text  = "#{ name }"
      text += " (#{ unit })" if unit.present?
      return text
    end
end
