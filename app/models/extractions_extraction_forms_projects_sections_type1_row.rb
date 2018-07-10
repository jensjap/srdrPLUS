# Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1Row. This is meant to be Outcome Population.
class ExtractionsExtractionFormsProjectsSectionsType1Row < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  # We need to create the four ResultStatisticSections:
  #   - Descriptive Statistics
  #   - Between Arm Comparisons
  #   - Within Arm Comparisons
  #   - NET Change
  after_create :create_default_result_statistic_sections
  after_create :create_default_type1_row_columns

  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_type1_rows
  belongs_to :population_name,                                      inverse_of: :extractions_extraction_forms_projects_sections_type1_rows

  has_many :comparable_elements, as: :comparable, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_type1_row_columns, dependent: :destroy, inverse_of: :extractions_extraction_forms_projects_sections_type1_row

  has_many :result_statistic_sections, dependent: :destroy, inverse_of: :population, foreign_key: 'population_id'

  accepts_nested_attributes_for :population_name, reject_if: :all_blank
  accepts_nested_attributes_for :extractions_extraction_forms_projects_sections_type1_row_columns, reject_if: :all_blank, allow_destroy: true

  delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1

  def descriptive_statistics_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 1)
  end

  def between_arm_comparisons_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 2)
  end

  def within_arm_comparisons_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 3)
  end

  def net_difference_comparisons_section
    result_statistic_sections.find_by(result_statistic_section_type_id: 4)
  end

  # Do not overwrite existing entries but associate to one that already exists or create a new one.
  #
  # In nested forms, the *_attributes hash will have IDs for entries that
  # are being modified (i.e. are tied to an existing record). We do not want to
  # change their values, but find one that already exists and then associate
  # to that one instead. If no such object exists we create it and associate to
  # it as well. Call super to update all the attributes of all submitted records.
  #
  # Note: This actually breaks validation. Presumably because validations happen
  #       later, after calling super. This is not a problem since there's
  #       nothing inherently wrong with creating an multiple associations.
  def population_name_attributes=(attributes)
    ExtractionsExtractionFormsProjectsSectionsType1Row.transaction do
      attributes.delete(:id)  # Remove ID from hash since this may carry the ID of
                              # the object we are trying to change.
      self.population_name = PopulationName.find_or_create_by!(attributes)
      attributes[:id] = self.population_name.id  # Need to put this back in, otherwise rails will
                                                # try to create this record, since its ID is
                                                # missing and it assumes it's a new item.
    end
    super
  end

  private

    def create_default_result_statistic_sections
      result_statistic_sections.create!([
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Descriptive Statistics') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Between Arm Comparisons') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'Within Arm Comparisons') },
        { result_statistic_section_type: ResultStatisticSectionType.find_by(name: 'NET Change') },
      ])
    end

    def create_default_type1_row_columns
      create_appropriate_number_of_type1_row_columns
    end

    def create_appropriate_number_of_type1_row_columns
      # Need to reload self.question here because it is being cached and its CollectionProxy
      # doesn't have the newly created extractions_extraction_forms_projects_sections_type1_row yet.
      self.extractions_extraction_forms_projects_sections_type1.reload if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.blank?

      if self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count == 0

        # If this is the first/only row then we default to creating (arbitrarily) 1 column.
        self.extractions_extraction_forms_projects_sections_type1_row_columns.create(timepoint_name: TimepointName.first, is_baseline: true)

      else

        # Otherwise, create the same number of columns as other rows have.
        # I don't remember why we did -1 here.
        #(self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count - 1).times do |c|
        self.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.count.times do |c|
          self.extractions_extraction_forms_projects_sections_type1_row_columns.create
        end

      end
    end
end
