class Question < ApplicationRecord
  include SharedOrderableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :create_default_question_rows

  after_save :ensure_matrix_column_headers

  before_validation -> { set_ordering_scoped_by(:extraction_forms_projects_section_id) }

  belongs_to :extraction_forms_projects_section, inverse_of: :questions
  belongs_to :question_type, inverse_of: :questions

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :question_rows, dependent: :destroy, inverse_of: :question

  accepts_nested_attributes_for :question_rows

  delegate :extraction_forms_project, to: :extraction_forms_projects_section
  delegate :section, to: :extraction_forms_projects_section

  validates :ordering, presence: true

  private

    def create_default_question_rows
      if %w(Text Checkbox Dropdown Radio).include? self.question_type.name
      #if [1, 2, 3, 4].include? self.question_type.id
        self.question_rows.create
      elsif %w(Matrix\ Text Matrix\ Checkbox Matrix\ Dropdown Matrix\ Radio).include? self.question_type.name
      #elsif [5, 6, 7, 8].include? self.question_type.id
        self.question_rows.create
        self.question_rows.create
      else
        raise 'Unknown QuestionType'
      end
    end

    #!!! May need to rethink this.
    def ensure_matrix_column_headers
      if self.question_type.name.include? 'Matrix'
        first_row = self.question_rows.first
        rest_rows = self.question_rows[1..-1]

        column_headers = []

        first_row.question_row_columns.each do |c|
          column_headers << c.name
        end

        rest_rows.each do |r|
          r.question_row_columns.each_with_index do |rc, idx|
            rc.name = column_headers[idx]
            rc.save
          end
        end
      end
    end
end
