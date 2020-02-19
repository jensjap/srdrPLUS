# == Schema Information
#
# Table name: extraction_forms_projects_sections_type1s
#
#  id                                   :integer          not null, primary key
#  extraction_forms_projects_section_id :integer
#  type1_id                             :integer
#  type1_type_id                        :integer
#  deleted_at                           :datetime
#  active                               :boolean
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class ExtractionFormsProjectsSectionsType1 < ApplicationRecord
  include SharedParanoiaMethods
  include SharedOrderableMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  before_validation -> { set_ordering_scoped_by(:extraction_forms_projects_section_id) }, on: :create

  belongs_to :extraction_forms_projects_section, inverse_of: :extraction_forms_projects_sections_type1s
  belongs_to :type1,                             inverse_of: :extraction_forms_projects_sections_type1s
  belongs_to :type1_type,                        inverse_of: :extraction_forms_projects_sections_type1s, optional: true

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :extraction_forms_projects_sections_type1_rows
  has_many :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy, inverse_of: :extraction_forms_projects_sections_type1
  has_many :timepoint_names, through: :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy

  validates :type1_id, uniqueness: { scope: :extraction_forms_projects_section_id }

  accepts_nested_attributes_for :extraction_forms_projects_sections_type1_rows, reject_if: :all_blank
  accepts_nested_attributes_for :type1, reject_if: :all_blank
  accepts_nested_attributes_for :timepoint_names, reject_if: :all_blank

  delegate :project, to: :extraction_forms_projects_section
  delegate :extraction_forms_project, to: :extraction_forms_projects_section

  def section_name
    extraction_forms_projects_section.section.name
  end

  def type1_attributes=(attributes)
    ExtractionFormsProjectsSectionsType1.transaction do
      attributes.delete(:id)  # Remove ID from hash since this may carry the ID of
                              # the object we are trying to change.
      self.type1 = Type1.find_or_create_by!(attributes)
      attributes[:id] = self.type1.id  # Need to put this back in, otherwise rails will
                                       # try to create this record, since its ID is
                                       # missing and it assumes it's a new item.
    end
    super
  end
end
