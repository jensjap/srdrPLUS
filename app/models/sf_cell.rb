class SfCell < ApplicationRecord
  belongs_to :sf_row
  belongs_to :sf_column
  has_many :sf_options, dependent: :destroy, inverse_of: :sf_cell
  has_many :sf_abstract_records, dependent: :destroy, inverse_of: :sf_cell
end
