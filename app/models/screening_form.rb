class ScreeningForm < ApplicationRecord
  belongs_to :project
  has_many :sf_questions, dependent: :destroy, inverse_of: :screening_form
end
