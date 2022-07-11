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
  ABSTRACT_SCREENING = 'AS'.freeze
  ABSTRACT_SCREENING_REJECTED = 'ASR'.freeze
  FULLTEXT_SCREENING = 'FS'.freeze
  FULLTEXT_SCREENING_REJECTED = 'FSR'.freeze
  DATA_EXTRACTION = 'DE'.freeze
  COMPLETED = 'C'.freeze
  SCREENING_STATUS_ORDER = [
    CITATION_POOL,
    ABSTRACT_SCREENING,
    ABSTRACT_SCREENING_REJECTED,
    FULLTEXT_SCREENING,
    FULLTEXT_SCREENING_REJECTED,
    DATA_EXTRACTION,
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
    new_index = index - 1 unless index.zero?
    update(screening_status: SCREENING_STATUS_ORDER[new_index])
  end

  def promote
    index = SCREENING_STATUS_ORDER.index(screening_status)
    new_index = index + 1 unless index + 1 >= SCREENING_STATUS_ORDER.length
    update(screening_status: SCREENING_STATUS_ORDER[new_index])
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
