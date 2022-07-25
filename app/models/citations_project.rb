# == Schema Information
#
# Table name: citations_projects
#
#  id                :integer          not null, primary key
#  citation_id       :integer
#  project_id        :integer
#  deleted_at        :datetime
#  active            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  consensus_type_id :integer
#  pilot_flag        :boolean
#  screening_status  :string(255)      default("CP"), not null
#

class CitationsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true

  CITATION_POOL = 'CP'.freeze
  ABSTRACT_SCREENING_UNSCREENED = 'ASU'.freeze
  ABSTRACT_SCREENING_PARTIALLY_SCREENED = 'ASPS'.freeze
  ABSTRACT_SCREENING_REJECTED = 'ASR'.freeze
  ABSTRACT_SCREENING_IN_CONFLICT = 'ASIC'.freeze
  ABSTRACT_SCREENING_ACCEPTED = 'ASA'.freeze
  FULLTEXT_SCREENING_UNSCREENED = 'FTU'.freeze
  FULLTEXT_SCREENING_PARTIALLY_SCREENED = 'FTPS'.freeze
  FULLTEXT_SCREENING_REJECTED = 'FTR'.freeze
  FULLTEXT_SCREENING_IN_CONFLICT = 'FTIC'.freeze
  FULLTEXT_SCREENING_ACCEPTED = 'FTA'.freeze
  DATA_EXTRACTION_NOT_YET_EXTRACTED = 'DENYE'.freeze
  DATA_EXTRACTION_IN_PROGRESS = 'DEIP'.freeze
  COMPLETED = 'C'.freeze

  SCREENING_STATUS_ORDER = [
    CITATION_POOL,
    ABSTRACT_SCREENING_UNSCREENED,
    ABSTRACT_SCREENING_PARTIALLY_SCREENED,
    ABSTRACT_SCREENING_REJECTED,
    ABSTRACT_SCREENING_IN_CONFLICT,
    FULLTEXT_SCREENING_UNSCREENED,
    FULLTEXT_SCREENING_PARTIALLY_SCREENED,
    FULLTEXT_SCREENING_REJECTED,
    FULLTEXT_SCREENING_IN_CONFLICT,
    DATA_EXTRACTION_NOT_YET_EXTRACTED,
    DATA_EXTRACTION_IN_PROGRESS,
    COMPLETED
  ].freeze
  DEMOTE = 'demote'.freeze
  PROMOTE = 'promote'.freeze

  scope :unlabeled,
        lambda { |project, count|
          includes(citation: [{ authors_citations: [:author] }, :keywords, :journal])
            .left_outer_joins(:labels)
            .where(labels: { id: nil },
                   project_id: project.id)
            .distinct
            .limit(count)
        }

  scope :labeled,
        lambda { |project, count|
          includes({ :citation => [{ authors_citations: [:author] }, :keywords, :journal],
                     labels => [:reasons] })
            .joins(:labels)
            .where(project_id: project.id)
            .distinct
            .limit(count)
        }

  belongs_to :citation, inverse_of: :citations_projects
  belongs_to :project, inverse_of: :citations_projects, touch: true

  has_one :prediction, dependent: :destroy
  has_one :priority, dependent: :destroy

  has_many :extractions, dependent: :destroy
  has_many :abstract_screenings_citations_projects
  has_many :abstract_screening_results, through: :abstract_screenings_citations_projects

  # TODO
  has_many :labels, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings

  has_and_belongs_to_many :abstract_screenings

  accepts_nested_attributes_for :citation, reject_if: :all_blank

  # We find all CitationsProject entries that have the exact same citation_id
  # and project_id. Then we pick the first (oldest) one. We refer to it as the
  # "Master CP" and link associations from all other CitationsProject entries
  # to the "Master CP"
  def dedupe
    citations_projects = CitationsProject.where(
      citation_id:,
      project_id:
    ).to_a
    master_citations_project = citations_projects.shift
    citations_projects.each do |cp|
      dedupe_update_associations(master_citations_project, cp)
      cp.destroy
    end
  end

  def demote
    index = SCREENING_STATUS_ORDER.index(screening_status)
    case index
    when 0
      nil
    when 1..4
      update(screening_status: SCREENING_STATUS_ORDER[3])
    when 5..8
      update(screening_status: SCREENING_STATUS_ORDER[7])
    when 9..10
      update(screening_status: SCREENING_STATUS_ORDER[7])
    end
  end

  def promote
    index = SCREENING_STATUS_ORDER.index(screening_status)
    case index
    when 0, 1..4
      update(screening_status: SCREENING_STATUS_ORDER[5])
    when 5..8
      update(screening_status: SCREENING_STATUS_ORDER[9])
    end
  end

  def self.dedupe_update_associations(master_cp, cp_to_remove)
    cp_to_remove.extractions.each do |e|
      e.dup.update_attributes(citations_project_id: master_cp.id)
    end
    cp_to_remove.labels.each do |l|
      l.dup.update_attributes(citations_project_id: master_cp.id)
    end
    cp_to_remove.notes.each do |n|
      n.dup.update_attributes(notable_id: master_cp.id)
    end
    cp_to_remove.taggings.each do |t|
      t.dup.update_attributes(taggable_id: master_cp.id)
    end
  end
end
