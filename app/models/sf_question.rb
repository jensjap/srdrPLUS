class SfQuestion < ApplicationRecord
  belongs_to :screening_form
  has_many :sf_rows, dependent: :destroy, inverse_of: :sf_question
  has_many :sf_columns, dependent: :destroy, inverse_of: :sf_question
end
