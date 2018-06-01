class TimepointName < ApplicationRecord
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :timepoint_name

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
