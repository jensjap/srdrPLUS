# == Schema Information
#
# Table name: extractions_extraction_forms_projects_sections_type1_row_columns
#
#  id                                                          :integer          not null, primary key
#  extractions_extraction_forms_projects_sections_type1_row_id :integer
#  timepoint_name_id                                           :integer
#  deleted_at                                                  :datetime
#  created_at                                                  :datetime         not null
#  updated_at                                                  :datetime         not null
#

# Temporarily calling it ExtractionsExtractionFormsProjectsSectionsType1RowColumn. This is meant to be Outcome Timepoint.
class ExtractionsExtractionFormsProjectsSectionsType1RowColumn < ApplicationRecord
  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    ComparableElement.with_deleted.where(comparable_type: self.class, comparable_id: id).each(&:really_destroy!)
    tps_arms_rssms.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  after_commit :ensure_timepoints_across_populations, on: %i[create update]
  after_commit :set_extraction_stale, on: %i[create update destroy]

  after_destroy :remove_timepoints_across_populations
  before_destroy :remove_wac

  belongs_to :extractions_extraction_forms_projects_sections_type1_row,
             inverse_of: :extractions_extraction_forms_projects_sections_type1_row_columns
  belongs_to :timepoint_name,
             inverse_of: :extractions_extraction_forms_projects_sections_type1_row_columns

  has_many :tps_arms_rssms, dependent: :destroy, foreign_key: 'timepoint_id'
  has_one :comparable_element, as: :comparable

  accepts_nested_attributes_for :timepoint_name, reject_if: :all_blank

  # delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1_row

  def extraction
    ExtractionsExtractionFormsProjectsSectionsType1Row.with_deleted.find_by(id: extractions_extraction_forms_projects_sections_type1_row_id).try(:extraction)
  end

  def label_with_optional_unit
    text  = "#{timepoint_name.name}"
    text += " #{timepoint_name.unit}" if timepoint_name.unit.present?
    text
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
      attributes.delete(:id) # Remove ID from hash since this may carry the ID of
      # the object we are trying to change.
      self.timepoint_name = TimepointName.find_or_create_by!(attributes)
      attributes[:id] = timepoint_name.id # Need to put this back in, otherwise rails will
      # try to create this record, since its ID is
      # missing and it assumes it's a new item.
    end
    super
  end

  private

  def set_extraction_stale
    extraction.extraction_checksum.update(is_stale: true) unless extraction.nil? || extraction.deleted?
  end

  def ensure_timepoints_across_populations
    extractions_extraction_forms_projects_sections_type1_row
      .extractions_extraction_forms_projects_sections_type1
      .extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
      next if eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.find_by(
        timepoint_name:
      )

      eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.create(
        timepoint_name:
      )
    end
  end

  def remove_timepoints_across_populations
    extractions_extraction_forms_projects_sections_type1_row
      .try(:extractions_extraction_forms_projects_sections_type1)
      .try(:extractions_extraction_forms_projects_sections_type1_rows)&.each do |eefpst1r|
      eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.where(
        timepoint_name:
      ).map { |eefpst1rc| eefpst1rc.try(:destroy) }
    end
  end

  def remove_wac
    if try(:comparable_element)
      wac = try(:comparable_element).comparates.first.comparate_group.comparison
      wac.destroy
    end
  end
end
