# == Schema Information
#
# Table name: projects
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  description                :text(65535)
#  attribution                :text(65535)
#  methodology_description    :text(65535)
#  prospero                   :string(255)
#  doi                        :string(255)
#  notes                      :text(65535)
#  funding_source             :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  authors_of_report          :text(65535)
#  exclude_personal_conflicts :boolean          default(FALSE), not null
#  as_limit_one_reason        :boolean          default(TRUE), not null
#  fs_limit_one_reason        :boolean          default(TRUE), not null
#  as_allow_adding_reasons    :boolean          default(TRUE), not null
#  as_allow_adding_tags       :boolean          default(TRUE), not null
#  fs_allow_adding_reasons    :boolean          default(TRUE), not null
#  fs_allow_adding_tags       :boolean          default(TRUE), not null
#

class Project < ApplicationRecord
  require 'csv'

  include SharedPublishableMethods
  include SharedQueryableMethods

  attr_accessor :create_empty,
                :is_amoeba_copy,
                :amoeba_copy_citations,
                :amoeba_copy_extraction_forms,
                :amoeba_copy_extractions,
                :amoeba_copy_labels

  searchkick callbacks: :async

  paginates_per 8

  scope :published, -> { joins(publishing: :approval) }
  scope :pending, lambda {
                    joins(:publishing).left_joins(publishing: :approval).where(publishings: { approvals: { id: nil } })
                  }
  scope :draft, lambda {
                  left_joins(:publishing).where(publishings: { id: nil })
                }
  scope :lead_by_current_user, -> {}

  amoeba do
    include_association :key_questions_projects
    include_association :mesh_descriptors_projects
    include_association :projects_tags
    include_association :projects_reasons
    include_association :citations_projects, if: :amoeba_copy_citations
    include_association :extraction_forms_projects, if: :amoeba_copy_extraction_forms
    include_association :extractions, if: :amoeba_copy_extractions

    customize(lambda { |original, copy|
      copy.amoeba_source_object = original
    })
    prepend name: 'Copy of '
  end

  after_create :create_default_extraction_form, unless: :create_empty
  # It seems that this is redundant for amoeba copy because we will skip this callback,
  # However we need this because it is needed in case of Distiller import.
  after_create :create_empty_extraction_form, if: :create_empty
  after_create :create_default_member

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :amoeba_source_object,
             class_name: 'Project',
             foreign_key: 'source_project_id',
             optional: true

  has_many :extractions, dependent: :destroy, inverse_of: :project
  has_many :exported_items, dependent: :destroy
  has_many :abstract_screenings, dependent: :destroy, inverse_of: :project
  has_many :abstract_screening_results, through: :abstract_screenings
  has_many :fulltext_screenings, dependent: :destroy, inverse_of: :project
  has_many :fulltext_screening_results, through: :fulltext_screenings

  has_many :projects_tags, dependent: :destroy
  has_many :tags, through: :projects_tags
  has_many :projects_reasons, dependent: :destroy
  has_many :reasons, through: :projects_reasons

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :project
  has_many :extraction_forms, through: :extraction_forms_projects

  has_many :key_questions_projects,
           dependent: :destroy, inverse_of: :project
  has_many :key_questions,
           through: :key_questions_projects

  has_many :extraction_forms_projects_sections,
           through: :extraction_forms_projects
  has_many :questions,
           through: :extraction_forms_projects_sections

  has_many :projects_users, dependent: :destroy, inverse_of: :project
  has_many :users, through: :projects_users

  has_many :citations_projects, dependent: :destroy, inverse_of: :project
  has_many :citations, through: :citations_projects

  has_many :sd_meta_data
  has_many :imports, through: :projects_users
  has_many :imported_files, through: :imports

  has_many :mesh_descriptors_projects, dependent: :destroy
  has_many :mesh_descriptors, through: :mesh_descriptors_projects

  has_many :ml_models_projects
  has_many :ml_models, through: :ml_models_projects

  has_one :data_audit, dependent: :destroy
  has_one :publishing, as: :publishable, dependent: :destroy
  has_one :screening_form, dependent: :destroy, inverse_of: :project
  # NOTE
  # I think we are using polymorphism incorrectly above. I think what we want is for each project to have at most one
  # publishing, therefore:
  #
  #   belongs_to :publishing, polymorphic: true
  #
  # and on the publishing:
  #
  #   has_many :publishable, as: :publishing
  #
  # is actually what we want.
  #
  # Birol
  has_many :external_service_providers_projects_users, dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :key_questions
  accepts_nested_attributes_for :citations_projects, allow_destroy: true
  accepts_nested_attributes_for :key_questions_projects, allow_destroy: true
  accepts_nested_attributes_for :projects_users, allow_destroy: true
  accepts_nested_attributes_for :imports, allow_destroy: true
  accepts_nested_attributes_for :imported_files, allow_destroy: true

  def project
    self
  end

  def type1s_used_by_projects_extractions(extraction_forms_projects_section_id)
    Type1
      .joins([{ extractions_extraction_forms_projects_sections_type1s: [{ extractions_extraction_forms_projects_section: [{ extraction: :project }] }] }])
      .where({
               extractions_extraction_forms_projects_sections_type1s: {
                 extractions_extraction_forms_projects_section: {
                   extractions: { project: self }
                 },
                 extractions_extraction_forms_projects_sections: { extraction_forms_projects_section: extraction_forms_projects_section_id }
               }
             })
  end

  def public?
    publishing.present? and publishing.approval.present?
  end

  def dei_blacklisted?
    begin
      # Load list of blacklisted projects from YAML file.
      data = YAML.load_file(Rails.root.join('config', 'dei-blacklist.yml'))
      blacklisted_project_ids = data.map { |item| item["project_id"] }
      blacklisted_project_ids.include?(self.id)
    rescue Errno::ENOENT => e
      return false
    end
  end

  def duplicate_key_question?
    kqps = key_questions_projects
    kqps.map(&:key_question).map(&:id).uniq.length < kqps.length if kqps.present?
  end

  def duplicate_extraction_form?
    extraction_forms.pluck(:name).uniq.length < extraction_forms.length
  end

  def key_questions_projects_array_for_select
    key_questions_projects.includes(:key_question).map { |kqp| [kqp.key_question.name, kqp.id] }
  end

  def publication_requested_at
    return publishing.created_at if publishing.present?

    nil
  end

  def creator
    User.joins({ projects_users: [:project] })
        .where(projects_users: { project_id: id })
        .first
  end

  def leaders
    projects_users.includes(:user).select(&:project_leader?).map(&:user)
  end

  def consolidators
    projects_users.includes(:user).select(&:project_consolidator?).map(&:user)
  end

  def contributors
    projects_users.includes(:user).select(&:project_contributor?).map(&:user)
  end

  def auditors
    projects_users.includes(:user).select(&:project_auditor?).map(&:user)
  end

  def members
    User.joins({ projects_users: :project })
        .where(projects_users: { project_id: id })
  end

  def consolidated_extraction(citations_project_id, current_user_id)
    non_c_extractions = extractions.unconsolidated.where(citations_project_id:)
    c_extraction = extractions.consolidated.find_by(citations_project_id:)
    return c_extraction if c_extraction.present?

    c_extraction = extractions.create(
      citations_project_id:,
      user_id: current_user_id,
      consolidated: true
    )
    ConsolidationService.clone_extractions(non_c_extractions, c_extraction, citations_project_id)
    c_extraction.reload
  end

  # returns nested hash:
  # {
  #   key: citations_project_id
  #   value: {
  #     data_discrepancy: Bool,
  #     extraction_ids: Array,
  #   },
  #   ...
  # }
  def citation_groups
    citation_groups = {}
    citation_groups[:citations_projects]      = {}
    citation_groups[:consolidations]          = {}
    citation_groups[:citations_project_ids]   = []
    citation_groups[:citations_project_count] = 0
    extractions.includes([{ citations_project: [{ citation: :journal }] }, :extraction_checksum]).each do |e|
      if citation_groups[:citations_projects].keys.include? e.citations_project_id
        citation_groups[:citations_projects][e.citations_project_id][:extractions] << e

        # If data_discrepancy is true then check for the existence of a consolidated
        # extraction and skip the discovery process.
        # Else run the discovery process.
        if citation_groups[:citations_projects][e.citations_project_id][:data_discrepancy]

          # We may skip this if we already determined that a consolidated extraction exists.
          unless citation_groups[:citations_projects][e.citations_project_id][:consolidated_status]
            citation_groups[:citations_projects][e.citations_project_id][:consolidated_status] = e.consolidated
          end
        else
          citation_groups[:citations_projects][e.citations_project_id][:data_discrepancy] =
            discover_extraction_discrepancy(
              citation_groups[:citations_projects][e.citations_project_id][:extractions].first, e
            )
        end
      else
        citation_groups[:citations_project_count] += 1
        citation_groups[:citations_project_ids] << e.citations_project_id
        citation_groups[:citations_projects][e.citations_project_id] = {}
        citation_groups[:citations_projects][e.citations_project_id][:citations_project_id] = e.citations_project_id
        citation_groups[:citations_projects][e.citations_project_id][:citation_id] = e.citation.id
        citation_groups[:citations_projects][e.citations_project_id][:citation_name_short] =
          e.citation.name.to_s.truncate(32)
        citation_groups[:citations_projects][e.citations_project_id][:citation_name_long] = e.citation.name.to_s
        citation_groups[:citations_projects][e.citations_project_id][:citation_info] = e.citation.info_zinger
        citation_groups[:citations_projects][e.citations_project_id][:data_discrepancy] = false
        citation_groups[:citations_projects][e.citations_project_id][:extractions] = [e]
        citation_groups[:citations_projects][e.citations_project_id][:consolidated_status] = e.consolidated
      end

      # Move the consolidated extraction from the list of extractions into [Array] of consolidations.
      next unless e.consolidated

      citation_groups[:consolidations][e.citations_project_id] = e
      citation_groups[:citations_projects][e.citations_project_id][:consolidated_extraction] = e
      citation_groups[:citations_projects][e.citations_project_id][:extractions].delete(e)
    end

    citation_groups
  end

  def has_duplicate_citations?
    is_any_citation_added_to_project_multiple_times =
      citations_projects
      .select(:citation_id, :project_id)
      .group(:citation_id, :project_id)
      .having('count(*) > 1').length > 0

    is_the_same_citation_added_to_the_database_multiple_times_and_referenced_multiple_times =
      citations
      .select(:pmid)
      .group(
        :citation_type_id,
        :name,
        :refman,
        :pmid,
        :abstract
      )
      .having('count(*) > 1')
      .length > 0

    is_any_citation_added_to_project_multiple_times || is_the_same_citation_added_to_the_database_multiple_times_and_referenced_multiple_times
  end

  def dedupe_citations
    # This takes care of citations that have been added to the project
    # multiple times.
    citations_projects
      .group(:citation_id, :project_id)
      .having('count(*) > 1')
      .each do |cp|
      cp.dedupe
    end

    sub_query = citations
                .select(
                  :citation_type_id,
                  :name,
                  :refman,
                  :pmid,
                  :abstract
                )
                .group(
                  :citation_type_id,
                  :name,
                  :refman,
                  :pmid,
                  :abstract
                )
                .having('count(*) > 1')
    citations_that_have_multiple_entries = citations.joins("INNER JOIN (#{sub_query.to_sql}) as t1").distinct

    # Group citations and dedupe each group.
    cthme_groups = citations_that_have_multiple_entries.group_by do |i|
      [i.citation_type_id, i.name, i.refman, i.pmid,
       i.abstract]
    end
    cthme_groups.each do |cthme_group|
      master_citation = cthme_group[1][0]
      cthme_group[1][1..-1].each do |cit|
        master_cp = CitationsProject.find_by(citation_id: master_citation.id, project_id: id)
        cp_to_remove = CitationsProject.find_by(citation_id: cit.id, project_id: id)
        CitationsProject.dedupe_update_associations(master_cp, cp_to_remove)
        cit.destroy
      end
    end
  end

  def key_questions_attributes=(attributes)
    attributes.each do |_i, kq_attrib|
      kq = KeyQuestion.find_or_create_by name: kq_attrib['name']
      KeyQuestionsProject.find_or_create_by project: self, key_question: kq
    end
    # super(attributes)
  end

  def display
    name
  end

  def check_publishing_eligibility
    []
  end

  def pct_extractions_with_no_data
    no_extractions_with_data = extractions.count do |extraction|
      extraction.has_data?
    end

    return 0 if extractions.count.eql?(0)

    ((extractions.count.to_f - no_extractions_with_data) / extractions.count * 100).round(1).to_s + '%'
  end

  def recent_exported_items
    exported_items.where('created_at >= ?', 1.week.ago).order(created_at: :desc)
  end

  def is_copy?
    amoeba_source_object.present?
  end

  private

  def process_list_of_pmids(listOf_pmids)
    citations_already_in_system = []
    citations_need_fetching = []

    listOf_pmids.each do |pmid|
      if c = Citation.find_by(pmid:)
        citations_already_in_system << c
      else
        citations_need_fetching << pmid
      end
    end

    [citations_already_in_system, citations_need_fetching]
  end

  # def separate_pubmed_keywords( kw_string )
  #  return kw_string.split( "; " ).map { |str| str.strip }
  # end

  def create_default_extraction_form
    return if amoeba_copy_extraction_forms

    extraction_forms_projects.create!(
      extraction_forms_project_type: ExtractionFormsProjectType.find_by(name: 'Standard'),
      extraction_form: ExtractionForm.find_by(name: 'ef1')
    )
  end

  def create_empty_extraction_form
    efp = ExtractionFormsProject.new(
      project: self,
      extraction_forms_project_type: ExtractionFormsProjectType.find_by(name: 'Standard'),
      extraction_form: ExtractionForm.find_by(name: 'ef1')
    )
    efp.create_empty = true
    efp.save!
  end

  def discover_extraction_discrepancy(extraction1, extraction2)
    #      e1 = Extraction.find(extraction1_id)
    #      e1_json = ApplicationController.new.view_context.render(

    #        locals: { extraction: e1 },
    #        formats: [:json],
    #        handlers: [:jbuilder]
    #      )
    #      e2 = Extraction.find(extraction2_id)
    #      e2_json = ApplicationController.new.view_context.render(
    #        partial: 'extractions/extraction_for_comparison_tool',
    #        locals: { extraction: e2 },
    #        formats: [:json],
    #        handlers: [:jbuilder]
    #      )
    #      e1_json = e1.to_builder.target!
    #      e2_json = e2.to_builder.target!

    e1_checksum = extraction1.extraction_checksum
    e2_checksum = extraction2.extraction_checksum

    e1_checksum.update_hexdigest if e1_checksum.is_stale
    e2_checksum.update_hexdigest if e2_checksum.is_stale

    !e1_checksum.hexdigest.eql?(e2_checksum.hexdigest)
  end

  def create_default_member
    return if create_empty

    attempted_current_user = User.try(:current)
    return unless attempted_current_user && projects_users.none? { |pu| pu.project_leader? }

    if (current_user_pu = ProjectsUser.find_by(project: self, user: attempted_current_user))
      current_user_pu.make_leader!
    else
      ProjectsUser.create!(user: User.current, project: self, permissions: 1)
    end
  end

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
