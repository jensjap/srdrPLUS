# == Schema Information
#
# Table name: questions
#
#  id                                   :integer          not null, primary key
#  extraction_forms_projects_section_id :integer
#  name                                 :text(65535)
#  description                          :text(65535)
#  deleted_at                           :datetime
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class Question < ApplicationRecord
  include SharedOrderableMethods
  include SharedSuggestableMethods

  acts_as_paranoid

  after_create :create_default_question_row
  after_save :ensure_matrix_column_headers

  before_validation -> { set_ordering_scoped_by(:extraction_forms_projects_section_id) }, on: :create

  belongs_to :extraction_forms_projects_section, inverse_of: :questions

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :dependencies, as: :dependable, dependent: :destroy

  has_many :key_questions_projects_questions, dependent: :destroy, inverse_of: :question
  has_many :key_questions_projects, through: :key_questions_projects_questions, dependent: :destroy

  has_many :question_rows, dependent: :destroy, inverse_of: :question
  has_many :question_row_columns, through: :question_rows
  has_many :question_row_column_fields, through: :question_row_columns

  accepts_nested_attributes_for :question_rows

  delegate :extraction_forms_project, to: :extraction_forms_projects_section
  delegate :position,                 to: :ordering
  delegate :project,                  to: :extraction_forms_project
  delegate :section,                  to: :extraction_forms_projects_section

  validates :ordering, presence: true

  amoeba do
    enable
    prepend :name => "Copy of '"
    append :name => "'"
    clone [:question_rows]
    #dependencies, orderings are polymorphic, not supported by amoeba
    #dependencies should not be copied anyway
    exclude_association [:ordering, :dependencies]
  end

  # Returns the question type based on how many how many rows/columns/answer choices the question has.
  def question_type
    if self.question_rows.length == 1 && self.question_rows.first.question_row_columns.length == 1
      return 'Single'
    end

    return "Matrix"
  end

  # Checks whether this is dependent on argument.
  #
  # (prerequisitable) -> Boolean
  def depends_on?(prerequisitable)
    return self.dependencies.any? { |d| d.prerequisitable == prerequisitable }
  end

  # Toggle dependency.
  #
  # (prerequisitable) -> nil
  def toggle_dependency(prerequisitable)
    # Capture the deleted dependency.
    dependency = self.dependencies.delete(self.dependencies.where(prerequisitable: prerequisitable))

    # If no dependency was deleted then we add it.
    self.dependencies << Dependency.create(prerequisitable: prerequisitable) if dependency.blank?

    return nil
  end

  def duplicate
    Question.transaction do
      duplicated_question = self.amoeba_dup
      duplicated_question.save
      return duplicated_question
      #duplicated_question = Question.new( name: self.name, description: self.description )
      #duplicated_question.key_questions << self.key_questions

      #self.question_rows.each do |question_row|
      #  question_row.question_row_columns.each do |question_row_column|
      #  end
      #end
    end
  end

  private

    def create_default_question_row
      self.question_rows.create
    end

    #!!! May need to rethink this.
    #    Who is actually responsible for this concern: Question,
    #    QuestionRow or QuestionRowColumn.
    def ensure_matrix_column_headers
      first_row = self.question_rows.first
      rest_rows = self.question_rows[1..-1]

      column_headers = []

      first_row.question_row_columns.each do |c|
        column_headers << c.name
      end

      rest_rows.each do |r|
        r.question_row_columns.each_with_index do |rc, idx|
          rc.update(name: column_headers[idx])
        end
      end
    end
end
