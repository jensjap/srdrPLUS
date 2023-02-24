# == Schema Information
#
# Table name: sf_rows
#
#  id             :bigint           not null, primary key
#  name           :string(255)
#  sf_question_id :bigint
#  position       :integer          default(999999)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class SfRow < ApplicationRecord
  belongs_to :sf_question
  has_many :sf_cells, dependent: :destroy, inverse_of: :sf_row
end
