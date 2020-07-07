# == Schema Information
#
# Table name: sd_meta_data
#
#  id                                          :integer          not null, primary key
#  project_id                                  :integer
#  report_title                                :string(255)
#  date_of_last_search                         :datetime
#  date_of_publication_to_srdr                 :datetime
#  date_of_publication_full_report             :datetime
#  stakeholder_involvement_extent              :text(65535)
#  authors_conflict_of_interest_of_full_report :text(65535)
#  stakeholders_conflict_of_interest           :text(65535)
#  protocol_link                               :text(65535)
#  full_report_link                            :text(65535)
#  structured_abstract_link                    :text(65535)
#  key_messages_link                           :text(65535)
#  abstract_summary_link                       :text(65535)
#  evidence_summary_link                       :text(65535)
#  disposition_of_comments_link                :text(65535)
#  srdr_data_link                              :text(65535)
#  most_previous_version_srdr_link             :text(65535)
#  most_previous_version_full_report_link      :text(65535)
#  overall_purpose_of_review                   :text(65535)
#  state                                       :string(255)      default("DRAFT"), not null
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  section_flag_0                              :boolean          default(FALSE), not null
#  section_flag_1                              :boolean          default(FALSE), not null
#  section_flag_2                              :boolean          default(FALSE), not null
#  section_flag_3                              :boolean          default(FALSE), not null
#  section_flag_4                              :boolean          default(FALSE), not null
#  section_flag_5                              :boolean          default(FALSE), not null
#  section_flag_6                              :boolean          default(FALSE), not null
#  report_accession_id                         :string(255)
#  authors                                     :text(65535)
#  section_flag_7                              :boolean          default(FALSE), not null
#  prospero_link                               :string(255)
#  review_type_id                              :bigint
#  section_flag_8                              :boolean          default(FALSE), not null
#

class SdMetaDatum < ApplicationRecord
  include SharedPublishableMethods
  include SharedProcessTokenMethods

  after_create :set_report_title

  attr_accessor :kqp_ids

  SECTIONS = [
    "Title, Funding Sources, and Dates",
    "Authors and Stakeholders",
    "URL Links",
    "Purpose, Analytic Framework, and Key Questions",
    "PICODTS",
    "Key Question Mapping",
    "Search Strategy and Results of Screening",
    "Risk of Bias and Overall Summary of Evidence",
    "Results for Individual Outcomes"
  ].freeze

  default_scope { order(id: :desc) }

  belongs_to :project, inverse_of: :sd_meta_data, optional: true
  belongs_to :review_type, inverse_of: :sd_meta_data, optional: true

  has_many :sd_key_questions, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :key_questions, -> { distinct }, through: :sd_key_questions

  has_many :sd_result_items, -> { ordered }, dependent: :destroy
  has_many :sd_narrative_results, through: :sd_result_items, dependent: :destroy
  has_many :sd_evidence_tables, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_network_meta_analysis_results, through: :sd_result_items, dependent: :destroy
  has_many :sd_pairwise_meta_analytic_results, through: :sd_result_items, dependent: :destroy
  has_many :sd_meta_regression_analysis_results, through: :sd_result_items, dependent: :destroy

  has_many :sd_key_questions_projects, through: :sd_key_questions, inverse_of: :sd_meta_datum
  has_many :project_key_questions, through: :sd_key_questions_projects, source: :key_question

  has_many :sd_key_questions_sd_picods, through: :sd_key_questions, dependent: :destroy

  has_many :sd_journal_article_urls, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_other_items, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy

  has_many :sd_search_strategies, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_search_databases, through: :sd_search_strategies

  has_many :sd_summary_of_evidences, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_grey_literature_searches, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_prisma_flows, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_picods, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :sd_analytic_frameworks, -> { ordered }, inverse_of: :sd_meta_datum, dependent: :destroy

  has_many :funding_sources_sd_meta_data, inverse_of: :sd_meta_datum, dependent: :destroy
  has_many :funding_sources, through: :funding_sources_sd_meta_data

  has_many :sd_meta_data_queries, dependent: :destroy

  has_many :publishings, as: :publishable, dependent: :destroy
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

  has_one_attached :report_file

  accepts_nested_attributes_for :sd_key_questions, allow_destroy: true
  accepts_nested_attributes_for :sd_journal_article_urls, allow_destroy: true
  accepts_nested_attributes_for :sd_other_items, allow_destroy: true
  accepts_nested_attributes_for :sd_analytic_frameworks, allow_destroy: true
  accepts_nested_attributes_for :sd_picods, allow_destroy: true
  accepts_nested_attributes_for :sd_search_strategies, allow_destroy: true
  accepts_nested_attributes_for :sd_grey_literature_searches, allow_destroy: true
  accepts_nested_attributes_for :sd_summary_of_evidences, allow_destroy: true
  accepts_nested_attributes_for :sd_prisma_flows, allow_destroy: true
  accepts_nested_attributes_for :sd_result_items, allow_destroy: true

  def report
    Report.all.find { |report_meta| report_meta.accession_id == self.report_accession_id }
  end

  def create_fuzzy_matches
    sd_key_questions.each do |sd_kq|
      fuzzy_match = sd_kq.fuzzy_match
      SdKeyQuestionsProject.create(sd_key_question_id: sd_kq.id, key_questions_project_id: fuzzy_match.id) if fuzzy_match
    end
  end

  def all_sections_complete?
    section_statuses.all? { |status| status == true }
  end

  def progress_meter_width
    progress_meter_width = ((SECTIONS.length - incomplete_sections.length).to_f * 100 / SECTIONS.length.to_f).round.to_s
  end

  def incomplete_sections
    incomplete_sections = []

    section_statuses.each_with_index { |el, idx| incomplete_sections << SECTIONS[idx] unless el }
    incomplete_sections
  end

  def section_statuses
    (0..8).to_a.map do |i|
      section = "section_flag_" + i.to_s
      self[section]
    end
  end

  def toggle_state
    new_state = state == "DRAFT" ? "COMPLETED" : "DRAFT"
    update(state: new_state)
  end

  def funding_source_ids=(tokens)
    tokens.map do |token|
      resource = FundingSource.new
      save_resource_name_with_token(resource, token)
    end
    super
  end

  def review_type_id=(token)
    resource = ReviewType.new
    save_resource_name_with_token(resource, token)
    super
  end

  def data_analysis_level_id=(token)
    resource = DataAnalysisLevel.new
    save_resource_name_with_token(resource, token)
    super
  end

  private
    def set_report_title
      self.update( report_title: self.report&.title )
    end
end
