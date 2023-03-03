# == Schema Information
#
# Table name: sd_key_questions
#
#  id                     :integer          not null, primary key
#  sd_meta_datum_id       :integer
#  sd_key_question_id     :integer
#  key_question_id        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  includes_meta_analysis :boolean
#  pos                    :integer          default(999999)
#

class SdKeyQuestion < ApplicationRecord
  default_scope { order(:pos, :id) }

  include SharedProcessTokenMethods
  belongs_to :sd_meta_datum, inverse_of: :sd_key_questions
  belongs_to :key_question, inverse_of: :sd_key_questions, optional: true

  has_many :sd_result_items, inverse_of: :sd_key_question, dependent: :nullify
  has_many :sd_key_questions_key_question_types, inverse_of: :sd_key_question, dependent: :destroy
  has_many :key_question_types, through: :sd_key_questions_key_question_types

  # to enable sub questions
  # belongs_to :sd_key_question, inverse_of: :sd_key_questions, optional: true
  # has_many :sd_key_questions, inverse_of: :sd_key_question

  has_many :sd_key_questions_projects, inverse_of: :sd_key_question, dependent: :destroy
  has_many :srdr_key_questions, through: :sd_key_questions_projects, source: :key_question

  has_many :sd_key_questions_sd_picods, inverse_of: :sd_key_question, dependent: :destroy
  has_many :sd_picods, through: :sd_key_questions_sd_picods

  has_many :sd_summary_of_evidences, inverse_of: :sd_key_question, dependent: :nullify

  accepts_nested_attributes_for :sd_key_questions_key_question_types, allow_destroy: true

  delegate :project, to: :sd_meta_datum

  def key_question_id=(token)
    save_resource_name_with_token(KeyQuestion.new, token)
    super
  end

  def name
    try(:key_question).try(:name)
  end

  def key_question_type_ids=(tokens)
    tokens.map do |token|
      resource = KeyQuestionType.new
      save_resource_name_with_token(resource, token)
    end
    super
  end

  def sd_key_questions_key_question_type_ids=(tokens)
    tokens.map do |token|
      new_resource = KeyQuestionType.new
      joint_class = SdKeyQuestionsKeyQuestionType
      save_resource_name_with_token(new_resource, token, self, joint_class)
    end
    super
  end

  def fuzzy_match
    fz = FuzzyMatch.new(sd_meta_datum.project.key_questions, read: :name)
    fz.find(key_question.name)
  end

  def key_question_name
    key_question&.name || ''
  end

  def key_question_name=(name)
    update(key_question: KeyQuestion.find_or_create_by(name:))
  end
end
