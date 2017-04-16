class KeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :key_question
  belongs_to :project

  validates :degree_id, :profile_id, presence: true
end
