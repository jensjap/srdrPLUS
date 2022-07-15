# == Schema Information
#
# Table name: projects
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  description             :text(65535)
#  attribution             :text(65535)
#  methodology_description :text(65535)
#  prospero                :string(255)
#  doi                     :string(255)
#  notes                   :text(65535)
#  funding_source          :string(255)
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  authors_of_report       :text(65535)
#

class Project < ApplicationRecord
  require 'csv'

  include SharedPublishableMethods
  include SharedQueryableMethods

  attr_accessor :create_empty

  acts_as_paranoid
  searchkick

  paginates_per 8

  scope :published, -> { joins(publishing: :approval) }
  scope :pending, lambda {
                    joins(:publishing).left_joins(publishing: :approval).where(publishings: { approvals: { id: nil } })
                  }
  scope :draft, lambda {
                  left_joins(:publishing).where(publishings: { id: nil })
                }
  scope :lead_by_current_user, -> {}

  after_create :create_default_extraction_form, unless: :create_empty
  after_create :create_empty_extraction_form, if: :create_empty
  after_create :create_default_perpetual_task, :create_default_member, :create_abstract_screening

  has_many :extractions, dependent: :destroy, inverse_of: :project
  has_many :teams, dependent: :destroy, inverse_of: :project
  has_many :abstract_screenings, dependent: :destroy, inverse_of: :project

  has_one :data_audit, dependent: :destroy
  has_one :publishing, as: :publishable, dependent: :destroy
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

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :project
  has_many :extraction_forms, through: :extraction_forms_projects, dependent: :destroy

  has_many :key_questions_projects,
           -> { ordered },
           dependent: :destroy, inverse_of: :project
  has_many :key_questions,
           -> { joins(key_questions_projects: :ordering) },
           through: :key_questions_projects, dependent: :destroy
  ## this does not feel right - Birol
  # jens 2019-06-17: I believe we ought to define the ordering via a scope block in has_many.
  # has_many :orderings, through: :key_questions_projects, dependent: :destroy

  has_many :extraction_forms_projects_sections,
           -> { ordered },
           through: :extraction_forms_projects
  has_many :questions,
           -> { ordered },
           through: :extraction_forms_projects_sections

  has_many :projects_studies, dependent: :destroy, inverse_of: :project
  has_many :studies, through: :projects_studies, dependent: :destroy

  has_many :projects_users, dependent: :destroy, inverse_of: :project
  has_many :projects_users_roles, through: :projects_users, dependent: :destroy
  has_many :users, through: :projects_users, dependent: :destroy

  has_many :citations_projects, dependent: :destroy, inverse_of: :project
  has_many :citations, through: :citations_projects

  has_many :labels, through: :citations_projects
  has_many :unlabeled_citations, lambda {
                                   where(labels: { id: nil })
                                 }, through: :citations_projects, source: :citations

  has_many :tasks, dependent: :destroy, inverse_of: :project
  has_many :assignments, through: :tasks, dependent: :destroy

  has_many :screening_options
  has_many :screening_option_types, through: :screening_options

  has_many :sd_meta_data
  has_many :imports, through: :projects_users, dependent: :destroy
  has_many :imported_files, through: :imports, dependent: :destroy

  has_many :mesh_descriptors_projects, dependent: :destroy
  has_many :mesh_descriptors, through: :mesh_descriptors_projects

  validates :name, presence: true

  # accepts_nested_attributes_for :extraction_forms_projects, reject_if: :all_blank, allow_destroy: true
  # accepts_nested_attributes_for :key_questions_projects, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :key_questions
  accepts_nested_attributes_for :citations
  accepts_nested_attributes_for :citations_projects, allow_destroy: true
  accepts_nested_attributes_for :tasks, allow_destroy: true
  accepts_nested_attributes_for :assignments, allow_destroy: true
  accepts_nested_attributes_for :key_questions_projects, allow_destroy: true
  # accepts_nested_attributes_for :orderings
  accepts_nested_attributes_for :projects_users, allow_destroy: true
  accepts_nested_attributes_for :screening_options, allow_destroy: true
  accepts_nested_attributes_for :imports, allow_destroy: true
  accepts_nested_attributes_for :imported_files, allow_destroy: true

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

  def screening_teams
    teams.where(team_type: TeamType.find_by(name: 'Citation Screening Team')).or(teams.where(team_type: TeamType.find_by(name: 'Citation Screening Blacklist')))
  end

  def public?
    publishing.present? and publishing.approval.present?
  end

  def duplicate_key_question?
    kqps = key_questions_projects
    return kqps.map(&:key_question).map(&:id).uniq.length < kqps.length if kqps.present?
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
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
        .where(projects_users: { project_id: id })
        .first
  end

  def leaders
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
        .where(projects_users: { project_id: id })
        .where(projects_users: { projects_users_roles: { roles: { name: 'Leader' } } })
  end

  def consolidators
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
        .where(projects_users: { project_id: id })
        .where(projects_users: { projects_users_roles: { roles: { name: 'Consolidator' } } })
  end

  def contributors
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
        .where(projects_users: { project_id: id })
        .where(projects_users: { projects_users_roles: { roles: { name: 'Contributor' } } })
  end

  def auditors
    User.joins({ projects_users: [:project, { projects_users_roles: :role }] })
        .where(projects_users: { project_id: id })
        .where(projects_users: { projects_users_roles: { roles: { name: 'Auditor' } } })
  end

  def members
    User.joins({ projects_users: :project })
        .where(projects_users: { project_id: id })
  end

  def consolidated_extraction(citations_project_id, current_user_id)
    consolidated_extraction = extractions.consolidated.find_by(citations_project_id:)
    return consolidated_extraction if consolidated_extraction.present?

    extractions.create(
      citations_project_id:,
      projects_users_role: ProjectsUsersRole.find_or_create_by!(
        projects_user: ProjectsUser.find_by(project: self, user_id: current_user_id),
        role: Role.find_by(name: 'Consolidator')
      ),
      consolidated: true
    )
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
      .select(:id)
      .group(
        :citation_type_id,
        :name,
        :refman,
        :pmid,
        :abstract
      )
      .having('count(*) > 1').length > 0

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
    cthme_groups = citations_that_have_multiple_entries.group_b y { |i|
                                                                  [i.citation_type_id, i.name, i.refman, i.pmid,
                                                                   i.abstract]
                                                                }
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
    extraction_forms_projects.create!(
      extraction_forms_project_type: ExtractionFormsProjectType.find_by(name: 'Standard'),
      extraction_form: ExtractionForm.find_by(name: 'ef1')
    )
  end

  def create_empty_extraction_form
    efp = ExtractionFormsProject.new(project: self,
                                     extraction_forms_project_type: ExtractionFormsProjectType.first,
                                     extraction_form: ExtractionForm.first)
    efp.create_empty = true
    efp.save!
  end

  def create_default_perpetual_task
    new_task = tasks.create!(task_type: TaskType.find_by(name: 'Perpetual'))
    # ProjectsUsersRole.by_project(@project).each do |pur|
    #  new_task.assignments << Assignment.create!(projects_users_role: pur)
    # end
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
    if User.try(:current)
      projects_user = projects_users.select { |pu| pu.user == User.current }.first
      projects_user ||= ProjectsUser.create(user: User.current, project: self)
      unless projects_user.roles.where(name: 'Leader').present?
        projects_user.roles << Role.where(name: 'Leader')
        projects_user.save
      end
    end
  end

  def create_abstract_screening
    abstract_screenings.create(default: true)
  end
end
