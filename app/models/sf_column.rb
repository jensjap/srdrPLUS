# == Schema Information
#
# Table name: sf_columns
#
#  id             :bigint           not null, primary key
#  name           :string(255)
#  sf_question_id :bigint
#  pos            :integer          default(999999)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class SfColumn < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :sf_question
  has_many :sf_cells, dependent: :destroy, inverse_of: :sf_row
end
