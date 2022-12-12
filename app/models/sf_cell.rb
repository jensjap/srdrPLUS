# == Schema Information
#
# Table name: sf_cells
#
#  id            :bigint           not null, primary key
#  sf_row_id     :bigint
#  sf_column_id  :bigint
#  cell_type     :string(255)      not null
#  min           :integer          default(0), not null
#  max           :integer          default(255), not null
#  with_equality :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class SfCell < ApplicationRecord
  belongs_to :sf_row
  belongs_to :sf_column
  has_many :sf_options, dependent: :destroy, inverse_of: :sf_cell
  has_many :sf_abstract_records, dependent: :destroy, inverse_of: :sf_cell
  has_many :sf_fulltext_records, dependent: :destroy, inverse_of: :sf_cell

  TEXT = 'text'.freeze
  NUMERIC = 'numeric'.freeze
  CHECKBOX = 'checkbox'.freeze
  DROPDOWN = 'dropdown'.freeze
  RADIO = 'radio'.freeze
  SELECT_ONE = 'select-one'.freeze
  SELECT_MULTIPLE = 'select-multiple'.freeze
end
