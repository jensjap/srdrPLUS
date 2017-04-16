class KeyQuestion < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :key_question
  has_many :projects, through: :key_questions_projects, dependent: :destroy
end
