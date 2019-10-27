# == Schema Information
#
# Table name: extractions_extraction_forms_projects_sections_type1_row_columns
#
#  id                                                          :integer          not null, primary key
#  extractions_extraction_forms_projects_sections_type1_row_id :integer
#  timepoint_name_id                                           :integer
#  is_baseline                                                 :boolean          default(FALSE)
#  deleted_at                                                  :datetime
#  created_at                                                  :datetime         not null
#  updated_at                                                  :datetime         not null
#

# Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1RowColumn. This is meant to be Outcome Timepoint.
class ExtractionsExtractionFormsProjectsSectionsType1RowColumn < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_commit :ensure_only_one_baseline
  after_commit :ensure_timepoints_across_populations
  after_commit :set_extraction_stale, on: [:create, :update, :destroy]

  after_destroy :remove_timepoints_across_populations

  belongs_to :extractions_extraction_forms_projects_sections_type1_row, inverse_of: :extractions_extraction_forms_projects_sections_type1_row_columns
  belongs_to :timepoint_name,                                           inverse_of: :extractions_extraction_forms_projects_sections_type1_row_columns

  accepts_nested_attributes_for :timepoint_name, reject_if: :all_blank

  delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1_row

  def label_with_baseline_indicator
    text  = "#{ timepoint_name.name }"
    text += " #{ timepoint_name.unit }" if timepoint_name.unit.present?
    text += " (Baseline)" if is_baseline
    return text
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
  def timepoint_name_attributes=(attributes)
    ExtractionsExtractionFormsProjectsSectionsType1RowColumn.transaction do
      attributes.delete(:id)  # Remove ID from hash since this may carry the ID of
                              # the object we are trying to change.
      self.timepoint_name = TimepointName.find_or_create_by!(attributes)
      attributes[:id] = self.timepoint_name.id  # Need to put this back in, otherwise rails will
                                                # try to create this record, since its ID is
                                                # missing and it assumes it's a new item.
    end
    super
  end

  private

    def set_extraction_stale
      self.extraction.extraction_checksum.update( is_stale: true ) 
    end

    def ensure_only_one_baseline
      return false unless extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.section.name == 'Outcomes'
      if is_baseline
        extractions_extraction_forms_projects_sections_type1_row.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
          tp.update_attribute(:is_baseline, false) unless tp == self
        end
      end
    end

    def ensure_timepoints_across_populations
      self.
        extractions_extraction_forms_projects_sections_type1_row.
        extractions_extraction_forms_projects_sections_type1.
        extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
        eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.create(
          timepoint_name: self.timepoint_name
        ) unless eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.find_by(
          timepoint_name: self.timepoint_name
        )
      end
    end

    def remove_timepoints_across_populations
      self.
        extractions_extraction_forms_projects_sections_type1_row.
        extractions_extraction_forms_projects_sections_type1.
        extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
        eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.where(
          timepoint_name: self.timepoint_name
        ).map { |eefpst1rc| eefpst1rc.try(:destroy) }
      end
    end
end
