# == Schema Information
#
# Table name: sf_questions
#
#  id                :bigint           not null, primary key
#  screening_form_id :bigint
#  name              :string(255)
#  description       :text(65535)
#  pos               :integer          default(999999)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
class SfQuestion < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :screening_form
  has_many :sf_rows, dependent: :destroy, inverse_of: :sf_question
  has_many :sf_columns, dependent: :destroy, inverse_of: :sf_question
end
