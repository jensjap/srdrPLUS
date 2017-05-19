class QuestionType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :questions, dependent: :destroy, inverse_of: :question_type
end
