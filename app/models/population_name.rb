class PopulationName < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :extractions_extraction_forms_projects_sections_type1_rows, dependent: :destroy, inverse_of: :population_name

  validates :description, uniqueness: { scope: :name }

  private

    def select_label
      text  = "#{ name }"
      text += " (#{ description })" if description.present?
      return text
    end
end
