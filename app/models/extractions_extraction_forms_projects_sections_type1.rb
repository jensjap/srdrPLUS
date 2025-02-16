# == Schema Information
#
# Table name: extractions_extraction_forms_projects_sections_type1s
#
#  id                                               :integer          not null, primary key
#  type1_type_id                                    :integer          default(1)
#  extractions_extraction_forms_projects_section_id :integer
#  type1_id                                         :integer
#  units                                            :string(255)
#  created_at                                       :datetime         not null
#  updated_at                                       :datetime         not null
#  pos                                              :integer          default(999999)
#

class ExtractionsExtractionFormsProjectsSectionsType1 < ApplicationRecord
  attr_accessor :is_amoeba_copy
  attr_writer :should  # Need this to accept an attribute on the fly when making bulk changes to the eefpst1 within consolidation tool.

  paginates_per 1

  default_scope { order(:pos, :id) }

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

  amoeba do
    exclude_association :extractions_extraction_forms_projects_sections_question_row_column_fields
    exclude_association :extractions_extraction_forms_projects_sections_followup_fields
    exclude_association :tps_arms_rssms

    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  after_create :create_default_type1_rows
  after_commit :set_extraction_stale, on: %i[create update destroy]
  after_save :ensure_matrix_column_headers

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :type1_type,
             inverse_of: :extractions_extraction_forms_projects_sections_type1s, optional: true
  belongs_to :extractions_extraction_forms_projects_section,
             inverse_of: :extractions_extraction_forms_projects_sections_type1s
  belongs_to :type1,
             inverse_of: :extractions_extraction_forms_projects_sections_type1s

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

  has_one :statusing, as: :statusable, dependent: :destroy
  has_one :status, through: :statusing

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

  # Search for the newest comparison in the extraction. Then copy all BAC
  # and WAC from that comparison's parent outcome to the current outcome.
  # For WAC only copy comparison if timepoint name and unit match.
  #
  # !!!TODO: If no comparisons exist then create default comparison using the first
  # available comparates.
  # !!!TODO: check that WAC comparison have matching timepoints before copying.
  #
  # Is this accurate? Should comparisons be copied across populations by default
  # when adding comparisons?
  def assist_with_comparisons
    comparisons = collect_all_comparisons_in_extraction
    latest_comparison = comparisons.order(created_at: :desc).first

    if latest_comparison
      comparison_candidates_to_copy = find_sibiling_comparisons_to_copy(latest_comparison)
      self.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
        bac_rss = identify_rss(:bac, eefpst1r)
        wac_rss = identify_rss(:wac, eefpst1r)
        add_comparison_candidates_to_copy(eefpst1r, bac_rss, wac_rss, comparison_candidates_to_copy)
      end
    else
      # No comparisons exist in this extraction. Create default ones with first available arms
      # and timepoints.
      puts 'Nothing to do here..'
    end

    # self.update_columns(comparisons_assisted: true)
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

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end

  def collect_all_comparisons_in_extraction
    Comparison
      .joins(
        result_statistic_sections: {
          population: {
            extractions_extraction_forms_projects_sections_type1: {
              extractions_extraction_forms_projects_section: :extraction
            }
          }
        }
      )
      .where(  # filter on current extraction.
        extractions_extraction_forms_projects_sections_type1_rows: {
          extractions_extraction_forms_projects_sections_type1s: {
            extractions_extraction_forms_projects_sections: {
              extractions: self.extraction
            }
          }
        }
      )
      .where(  # filter on BAC and WAC type RSS.
        result_statistic_sections: {
          result_statistic_section_type_id: [
            ResultStatisticSectionType::BAC,
            ResultStatisticSectionType::WAC
          ]
        }
      )
      # .where.not(  # filter out current outcome?
      #   extractions_extraction_forms_projects_sections_type1_rows: {
      #     extractions_extraction_forms_projects_sections_type1s: self
      #   }
      # )
  end

  def find_sibiling_comparisons_to_copy(comparison)
    Comparison
      .joins(result_statistic_sections: :population)
      .where(  # filter on current extraction.
        result_statistic_sections: {
          population: comparison.result_statistic_sections.map(&:population)
        }
      )
      .where(  # filter on BAC and WAC type RSS.
        result_statistic_sections: {
          result_statistic_section_type_id: [
            ResultStatisticSectionType::BAC,
            ResultStatisticSectionType::WAC
          ]
        }
      )
  end

  def identify_rss(rss_type, eefpst1r)
    rss_type_id = case rss_type
                  when :bac
                    ResultStatisticSectionType::BAC
                  when :wac
                    ResultStatisticSectionType::WAC
                  else
                    raise 'Fatal: unknown rss type.'
                  end

    rss_collection = eefpst1r.result_statistic_sections.where(result_statistic_section_type_id: rss_type_id)
    raise "Fatal: incorrect number of #{ rss_type.to_s } type result_statistic_sections" unless rss_collection.size.eql?(1)

    return rss_collection.first
  end

  def add_comparison_candidates_to_copy(eefpst1r, bac_rss, wac_rss, comparison_candidates_to_copy)
    comparison_candidates_to_copy.each do |comparison|
      begin
        case comparison.result_statistic_sections.first.result_statistic_section_type_id
        when ResultStatisticSectionType::BAC
          copy_comparison(comparison, bac_rss)
        when ResultStatisticSectionType::WAC
          copy_comparison(comparison, wac_rss)
        else
          raise 'Fatal: unknown rss type.'
        end
      rescue ActiveRecord::RecordInvalid => e
        debugger if Rails.env.development?
        puts e
        puts 'continuing..'
      end
    end
  end

  def copy_comparison(comparison, rss)
    comparison_copy = Comparison.create(is_anova: comparison.is_anova)
    comparison.comparate_groups.each do |comparate_group|
      comparate_group_copy = ComparateGroup.create(
        comparison: comparison_copy
      )
      comparate_group.comparates.each do |comparate|
        comparable_element_copy = ComparableElement.create(
          comparable_type: comparate.comparable_element.comparable_type,
          comparable_id: comparate.comparable_element.comparable_id
        )
        comparate_copy = Comparate.create(
          comparate_group: comparate_group_copy,
          comparable_element: comparable_element_copy
        )
      end
    end

    ComparisonsResultStatisticSection.create(
      comparison: comparison_copy,
      result_statistic_section: rss,
    )
  end
end
