class Question < ApplicationRecord
  include SharedOrderableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_rows

  before_validation -> { set_ordering_scoped_by(:extraction_forms_projects_section_id) }

  belongs_to :extraction_forms_projects_section, inverse_of: :questions
  belongs_to :question_type, inverse_of: :questions

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :question_rows, dependent: :destroy, inverse_of: :question

  #accepts_nested_attributes_for :question_rows

  delegate :extraction_forms_project, to: :extraction_forms_projects_section

  validates :ordering, presence: true

  private

    def create_default_question_rows
      case self.question_type
      when QuestionType.find(1)  # Text
        self.question_rows.create
      when QuestionType.find(2)  # Checkbox
        self.question_rows.create
      when QuestionType.find(3)  # Dropdown
        self.question_rows.create
      when QuestionType.find(4)  # Radio
        self.question_rows.create
      when QuestionType.find(5)  # Matrix Checkbox
        self.question_rows.create
        self.question_rows.create
      when QuestionType.find(6)  # Matrix Dropdown
        self.question_rows.create
        self.question_rows.create
      when QuestionType.find(7)  # Matrix Radio
        self.question_rows.create
        self.question_rows.create
      else
        raise 'Unknown QuestionType'
      end
    end
end
