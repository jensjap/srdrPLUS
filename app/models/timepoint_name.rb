class TimepointName < ApplicationRecord
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :timepoint_name

  private

    def select_label
      "#{ name } #{ unit }"
    end
end
