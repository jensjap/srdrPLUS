class ExtractionsExtractionFormsProjectsSectionsType1Row < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  # Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1RowColumn. This is meant to be Outcome Population.
  after_create :create_default_type1_row_columns
  after_save :ensure_only_one_baseline

  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_type1_rows

  has_many :comparable_elements, as: :comparable

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1_row

  delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1

  private

    def create_default_type1_row_columns
      create_appropriate_number_of_type1_row_columns
    end

    def create_appropriate_number_of_type1_row_columns
      # Need to reload self.question here because it is being cached and its CollectionProxy
      # doesn't have the newly created extractions_extraction_forms_projects_sections_type1_row yet.
      self.extractions_extraction_forms_projects_sections_type1.reload if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.blank?

      if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count == 0

        # If this is the first/only row then we default to creating (arbitrarily) 1 column.
        self.extractions_extraction_forms_projects_sections_type1_row_columns.create(name: 'All Participants', description: 'All patients enrolled in this study.')

      else

        # Otherwise, create the same number of columns as other rows have.
        # I don't remember why we did -1 here.
        #(self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count - 1).times do |c|
        self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count.times do |c|
          self.extractions_extraction_forms_projects_sections_type1_row_columns.create
        end

      end
    end

    def ensure_only_one_baseline
      return false unless extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.section.name == 'Outcomes'
      if is_baseline
        extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.each do |tp|
          tp.update_attribute(:is_baseline, false) unless tp == self
        end
      end
    end
end
