# == Schema Information
#
# Table name: abstract_screenings
#
#  id                      :bigint           not null, primary key
#  project_id              :bigint
#  abstract_screening_type :string(255)      default("single-perpetual"), not null
#  no_of_citations         :integer          default(0), not null
#  exclusive_users         :boolean          default(FALSE), not null
#  yes_tag_required        :boolean          default(FALSE), not null
#  no_tag_required         :boolean          default(FALSE), not null
#  maybe_tag_required      :boolean          default(FALSE), not null
#  yes_reason_required     :boolean          default(FALSE), not null
#  no_reason_required      :boolean          default(FALSE), not null
#  maybe_reason_required   :boolean          default(FALSE), not null
#  yes_note_required       :boolean          default(FALSE), not null
#  no_note_required        :boolean          default(FALSE), not null
#  maybe_note_required     :boolean          default(FALSE), not null
#  only_predefined_reasons :boolean          default(FALSE), not null
#  only_predefined_tags    :boolean          default(FALSE), not null
#  hide_author             :boolean          default(FALSE), not null
#  hide_journal            :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class AbstractScreening < ApplicationRecord
  SINGLE_PERPETUAL = 'single-perpetual'.freeze
  DOUBLE_PERPETUAL = 'double-perpetual'.freeze
  EXPERT_NEEDED_PERPETUAL = 'expert-needed-perpetual'.freeze
  ONLY_EXPERT_NOVICE_MIXED_PERPETUAL = 'only-expert-novice-mixed-perpetual'.freeze
  N_SIZE_SINGLE = 'n-size-single'.freeze
  N_SIZE_DOUBLE = 'n-size-double'.freeze
  N_SIZE_EXPERT_NEEDED = 'n-size-expert-needed'.freeze
  N_SIZE_ONLY_EXPERT_NOVICE_MIXED = 'n-size-only-expert-novice-mixed'.freeze
  PILOT = 'pilot'.freeze
  ABSTRACTSCREENINGTYPES = {
    SINGLE_PERPETUAL => 'Perpetual (Single)',
    DOUBLE_PERPETUAL => 'Perpetual (Double)',
    EXPERT_NEEDED_PERPETUAL => 'Perpetual (Expert Needed)',
    ONLY_EXPERT_NOVICE_MIXED_PERPETUAL => 'Perpetual (Only Mixed With Expert)',
    N_SIZE_SINGLE => 'Fixed N Size (Single)',
    N_SIZE_DOUBLE => 'Fixed N Size (Double)',
    N_SIZE_EXPERT_NEEDED => 'Fixed N Size (Expert Needed)',
    N_SIZE_ONLY_EXPERT_NOVICE_MIXED => 'Fixed N Size (Only Mixed With Expert)',
    PILOT => 'Pilot'
  }.freeze
  NON_PERPETUAL = [N_SIZE_SINGLE, N_SIZE_DOUBLE, PILOT]
  SINGLE_SCREENINGS = [SINGLE_PERPETUAL, N_SIZE_SINGLE]
  DOUBLE_SCREENINGS = [DOUBLE_PERPETUAL, N_SIZE_DOUBLE]
  ALL_SCREENINGS = [PILOT]

  validates_presence_of :abstract_screening_type

  belongs_to :project
  has_many :abstract_screenings_users
  has_many :users, through: :abstract_screenings_users

  has_many :abstract_screenings_reasons
  has_many :reasons, through: :abstract_screenings_reasons
  has_many :abstract_screenings_tags
  has_many :tags, through: :abstract_screenings_tags

  has_many :abstract_screening_results, dependent: :destroy, inverse_of: :abstract_screening

  def single_screening?
    SINGLE_SCREENINGS.include?(abstract_screening_type)
  end

  def double_screening?
    DOUBLE_SCREENINGS.include?(abstract_screening_type)
  end

  def all_screenings?
    ALL_SCREENINGS.include?(abstract_screening_type)
  end

  def reasons_object
    abstract_screenings_reasons = AbstractScreeningsReason.where(abstract_screening: self).includes(:reason)
    abstract_screenings_reasons.map do |abstract_screenings_reason|
      {
        id: abstract_screenings_reason.id,
        reason_id: abstract_screenings_reason.reason_id,
        name: abstract_screenings_reason.reason.name,
        pos: abstract_screenings_reason.pos,
        selected: false
      }
    end
  end

  def tags_object
    abstract_screenings_tags = AbstractScreeningsTag.where(abstract_screening: self).includes(:tag)
    abstract_screenings_tags.map do |abstract_screenings_tag|
      {
        id: abstract_screenings_tag.id,
        tag_id: abstract_screenings_tag.tag_id,
        name: abstract_screenings_tag.tag.name,
        pos: abstract_screenings_tag.pos,
        selected: false
      }
    end
  end

  def tag_options
    reqs = []
    reqs << 'Yes' if yes_tag_required
    reqs << 'No' if no_tag_required
    reqs << 'Maybe' if maybe_tag_required
    reqs
  end

  def reason_options
    reqs = []
    reqs << 'Yes' if yes_reason_required
    reqs << 'No' if no_reason_required
    reqs << 'Maybe' if maybe_reason_required
    reqs
  end

  def note_options
    reqs = []
    reqs << 'Yes' if yes_note_required
    reqs << 'No' if no_note_required
    reqs << 'Maybe' if maybe_note_required
    reqs
  end
end
