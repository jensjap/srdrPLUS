class ExtractionsExtractionFormsProjectsSectionsType1Row < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  # Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1RowColumn. This is meant to be Outcome Population.
  after_create :create_default_type1_row_columns

  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_type1_rows

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1_row

  private

    def create_default_type1_row_columns
      create_appropriate_number_of_type1_row_columns
    end

    def create_appropriate_number_of_type1_row_columns
      self.extractions_extraction_forms_projects_sections_type1_row_columns.create(name: 'All Participants', description: 'All patients enrolled in this study.')

      # Need to reload self.question here because it is being cached and its CollectionProxy
      # doesn't have the newly created question_row yet.
      self.extractions_extraction_forms_projects_sections_type1.reload if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.blank?

      if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count == 0

        # If this is the first/only row then we default to creating (arbitrarily) 1 column.
        self.extractions_extraction_forms_projects_sections_type1_row_columns.create

      else

        # Otherwise, create the same number of columns as other rows have.
        self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count.times do |c|
          self.extractions_extraction_forms_projects_sections_type1_row_columns.create
        end

      end
    end
end
