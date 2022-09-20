class SfFulltextRecord < ApplicationRecord
  belongs_to :sf_cell
  belongs_to :fulltext_screening_result

  delegate :sf_column, :sf_row, to: :sf_cell
end
