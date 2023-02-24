# == Schema Information
#
# Table name: extractions_extraction_forms_projects_sections_type1s
#
#  id                                               :integer          not null, primary key
#  type1_type_id                                    :integer
#  extractions_extraction_forms_projects_section_id :integer
#  type1_id                                         :integer
#  units                                            :string(255)
#  created_at                                       :datetime         not null
#  updated_at                                       :datetime         not null
#  position                                         :integer          default(999999)
#

class ExtractionsExtractionFormsProjectsSectionsType1 < ApplicationRecord
  # Need this to accept an attribute on the fly when making bulk changes to the eefpst1 within consolidation tool.
  attr_writer :should

  include SharedOrderableMethods

  has_one :statusing, as: :statusable, dependent: :destroy
  has_one :status, through: :statusing

  after_commit :set_extraction_stale, on: %i[create update destroy]

  paginates_per 1

  before_validation -> { set_ordering_scoped_by(:extractions_extraction_forms_projects_section_id) }, on: :create

  # !!! Implement this for type1 selection also.
  scope :extraction_collection, lambda { |section_name, efp_id|
                                  joins([:type1, { extractions_extraction_forms_projects_section: { extraction_forms_projects_section: %i[extraction_forms_project section] } }])
                                    .where(sections: { name: section_name })
                                    .where(extraction_forms_projects: { id: efp_id })
                                }

  scope :by_section_name_and_extraction_id_and_extraction_forms_project_id, lambda { |section_name, extraction_id, extraction_forms_project_id|
                                                                              joins([:type1, { extractions_extraction_forms_projects_section: [:extraction, { extraction_forms_projects_section: %i[extraction_forms_project section] }] }])
                                                                                .where(sections: { name: section_name })
                                                                                .where(extractions: { id: extraction_id })
                                                                                .where(extraction_forms_projects: { id: extraction_forms_project_id })
                                                                            }

  # Returns eefpst1s across all extractions for a particular citation and type1.
  scope :by_citations_project_and_type1, lambda { |citations_project_id, type1_id|
    joins(extractions_extraction_forms_projects_section: :extraction)
      .joins(:type1)
      .where(extractions_extraction_forms_projects_sections: { extraction_id: Extraction.where(citations_project_id:) })
      .where(type1_id:)
  }

  # Returns eefpst1s across a project for a particular type1.
  scope :by_project_and_type1, lambda { |project_id, type1_id|
    joins(extractions_extraction_forms_projects_section: { extraction_forms_projects_section: { extraction_forms_project: :project } })
      .joins(:type1)
      .where(extractions_extraction_forms_projects_sections: { extraction_forms_projects_sections: { extraction_forms_projects: { project_id: } } })
      .where(type1_id:)
  }

  after_create :create_default_type1_rows

  after_save :ensure_matrix_column_headers

  belongs_to :type1_type,
             inverse_of: :extractions_extraction_forms_projects_sections_type1s, optional: true
  belongs_to :extractions_extraction_forms_projects_section,
             inverse_of: :extractions_extraction_forms_projects_sections_type1s
  belongs_to :type1,
             inverse_of: :extractions_extraction_forms_projects_sections_type1s

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_type1_rows,                 dependent: :destroy,
                                                                                       inverse_of: :extractions_extraction_forms_projects_sections_type1
  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields, dependent: :nullify,
                                                                                       inverse_of: :extractions_extraction_forms_projects_sections_type1
  has_many :extractions_extraction_forms_projects_sections_followup_fields,            dependent: :nullify,
                                                                                       inverse_of: :extractions_extraction_forms_projects_sections_type1
  has_many :tps_arms_rssms,                                                            dependent: :destroy,
                                                                                       inverse_of: :extractions_extraction_forms_projects_sections_type1
  has_many :comparisons_arms_rssms,                                                    dependent: :destroy,
                                                                                       inverse_of: :extractions_extraction_forms_projects_sections_type1

  has_many :comparable_elements, as: :comparable, dependent: :destroy

  accepts_nested_attributes_for :extractions_extraction_forms_projects_sections_type1_rows, allow_destroy: true
  accepts_nested_attributes_for :type1, reject_if: :all_blank

  delegate :citation,          to: :extractions_extraction_forms_projects_section
  delegate :citations_project, to: :extractions_extraction_forms_projects_section
  delegate :extraction,        to: :extractions_extraction_forms_projects_section
  delegate :project, to: :extractions_extraction_forms_projects_section

  validates :type1, uniqueness: { scope: %i[extractions_extraction_forms_projects_section type1_type] }

  def type1_name_and_description
    text =  "#{type1.name}"
    text += " (#{type1.description})" if type1.description.present?
    text
  end

  # Fetch records for this particular extractions_extraction_forms_projects_sections_type1
  # by timepoint, arm, and measure.
  def tps_arms_rssms_values(eefpst1rc_id, rssm)
    recordables = tps_arms_rssms
                  .where(
                    timepoint_id: eefpst1rc_id,
                    result_statistic_sections_measure: rssm
                  )

    Record.where(recordable: recordables.first).first.try(:name).to_s.gsub(/\P{Print}|\p{Cf}/, '')
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
  def type1_attributes=(attributes)
    ExtractionsExtractionFormsProjectsSectionsType1.transaction do
      attributes.delete(:id) # Remove ID from hash since this may carry the ID of
      # the object we are trying to change.
      self.type1 = Type1.find_or_create_by!(attributes)
      attributes[:id] = type1.id # Need to put this back in, otherwise rails will
      # try to create this record, since its ID is
      # missing and it assumes it's a new item.
    end
    super
  end

  def extractions_extraction_forms_projects_sections_type1_row_columns_attributes=(attributes); end

  #  def to_builder
  #    Jbuilder.new do |json|
  #      json.name type1.name
  #      json.description type1.description
  #    end
  #  end

  def propagate_type1_change(propagation_scope, params)
    eefpst1s_to_update = []

    case propagation_scope
    when :citations
      citations_project = self.citations_project
      eefpst1s_to_update = ExtractionsExtractionFormsProjectsSectionsType1
                           .by_citations_project_and_type1(citations_project.id, type1.id)
                           .where.not(id:)
    #      eefpst1s_to_update = ExtractionsExtractionFormsProjectsSectionsType1
    #        .joins(extractions_extraction_forms_projects_section: [:extraction, :extraction_forms_projects_section])
    #        .joins(:type1)
    #        .where(extractions_extraction_forms_projects_sections: { extraction_id: Extraction.where(citations_project: citations_project) })
    #        .where(type1: self.type1)
    #        .where.not(id: self.id)
    when :project
      eefpst1s_to_update = ExtractionsExtractionFormsProjectsSectionsType1
                           .by_project_and_type1(project.id, type1.id)
                           .where.not(id:)
    #      eefpst1s_to_update = ExtractionsExtractionFormsProjectsSectionsType1
    #        .joins(extractions_extraction_forms_projects_section: { extraction_forms_projects_section: { extraction_forms_project: :project } })
    #        .joins(:type1)
    #        .where(extractions_extraction_forms_projects_sections: { extraction_forms_projects_sections: { extraction_forms_projects: { project: self.project } } })
    #        .where(type1: self.type1)
    #        .where.not(id: self.id)
    else
      raise 'Unknown propagation scope.'
    end

    eefpst1s_to_update.map { |eefpst1| eefpst1.update(params) }
  end

  # Create a hash of preview data for type1 change in 3 cases.
  # 1. No propagation.
  # 2. Propagation across extractions of the same citation.
  # 3. Propagation across project.
  def preview_type1_change_propagation
    return_data = {}
    return_data[false] = [self]
    return_data[:citations] =
      ExtractionsExtractionFormsProjectsSectionsType1
      .by_citations_project_and_type1(citations_project.id, type1.id)
      .includes(:type1, {
                  extractions_extraction_forms_projects_section: { extraction: { citations_project: :citation, projects_users_role: { projects_user: { user: :profile } } } }
                })
    return_data[:project] =
      ExtractionsExtractionFormsProjectsSectionsType1
      .by_project_and_type1(project.id, type1.id)
      .includes(:type1, {
                  extractions_extraction_forms_projects_section: { extraction: { citations_project: :citation, projects_users_role: { projects_user: { user: :profile } } } }
                })

    return_data
  end

  def statusing
    super || create_default_draft_status
  end

  def status
    super || create_default_draft_status.status
  end

  private

  def set_extraction_stale
    extraction.set_stale(true)
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
  #    def extractions_extraction_forms_projects_sections_type1_rows_attributes=(attributes)
  #      ExtractionsExtractionFormsProjectsSectionsType1Row.transaction do
  #        attributes.delete(:id)  # Remove ID from hash since this may carry the ID of
  #                                # the object we are trying to change.
  #        self.population_name = PopulationName.find_or_create_by!(attributes)
  #        attributes[:id] = self.population_name.id  # Need to put this back in, otherwise rails will
  #                                                   # try to create this record, since its ID is
  #                                                   # missing and it assumes it's a new item.
  #      end
  #      super
  #    end

  # Only create these for Outcomes.
  #
  # We only need this to run for consolidated extractions. Once default populations and timepoints are present we update their names in ensure_matrix_column_headers.
  def create_default_type1_rows
    if %w[Outcomes Diagnoses].include?(extractions_extraction_forms_projects_section.section_name) &&
       extractions_extraction_forms_projects_sections_type1_rows.blank?
      extractions_extraction_forms_projects_sections_type1_rows.create(population_name: PopulationName.first)
    end
  end

  def ensure_matrix_column_headers
    if (extractions_extraction_forms_projects_section.extraction_forms_projects_section.section.name == 'Outcomes') ||
       (extractions_extraction_forms_projects_section.extraction_forms_projects_section.section.name == 'Diagnoses')

      first_row = extractions_extraction_forms_projects_sections_type1_rows.first
      rest_rows = extractions_extraction_forms_projects_sections_type1_rows[1..-1]

      timepoint_name_ids = []

      first_row.extractions_extraction_forms_projects_sections_type1_row_columns.each do |c|
        timepoint_name_ids << c.timepoint_name.id
      end

      rest_rows.each do |r|
        r.extractions_extraction_forms_projects_sections_type1_row_columns.each_with_index do |rc, idx|
          rc.update(timepoint_name_id: timepoint_name_ids[idx])
        end
      end
    end
  end

  def create_default_draft_status
    create_statusing(status: Status.find_by(name: 'Draft'))
  end

  def section_name
    extractions_extraction_forms_projects_section.section_name
  end
end
