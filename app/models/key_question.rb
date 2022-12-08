# == Schema Information
#
# Table name: key_questions
#
#  id         :integer          not null, primary key
#  name       :text(65535)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class KeyQuestion < ApplicationRecord
  include SharedSuggestableMethods
  include SharedQueryableMethods

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :key_questions_projects, dependent: :destroy, inverse_of: :key_question
  has_many :projects,         through: :key_questions_projects
  has_many :extraction_forms, through: :key_questions_projects

  has_many :sd_key_questions, inverse_of: :key_question, dependent: :nullify
  has_many :sd_meta_data, through: :sd_key_questions

  validates :name, presence: true, uniqueness: { case_sensitive: true }
end
