# == Schema Information
#
# Table name: sf_abstract_records
#
#  id                           :bigint           not null, primary key
#  value                        :string(255)
#  followup                     :string(255)
#  equality                     :string(255)
#  sf_cell_id                   :bigint
#  abstract_screening_result_id :bigint
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
class SfAbstractRecord < ApplicationRecord
  belongs_to :sf_cell
  belongs_to :abstract_screening_result

  delegate :sf_column, :sf_row, to: :sf_cell
end
