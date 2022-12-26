# == Schema Information
#
# Table name: fulltext_screenings
#
#  id                      :bigint           not null, primary key
#  project_id              :bigint
#  fulltext_screening_type :string(255)      default("single-perpetual"), not null
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
class FulltextScreening < ApplicationRecord
  SINGLE_PERPETUAL = 'single-perpetual'.freeze
  DOUBLE_PERPETUAL = 'double-perpetual'.freeze
  N_SIZE_SINGLE = 'n-size-single'.freeze
  N_SIZE_DOUBLE = 'n-size-double'.freeze
  PILOT = 'pilot'.freeze
  FULLTEXTSCREENINGTYPES = {
    SINGLE_PERPETUAL => 'Perpetual (Single)',
    DOUBLE_PERPETUAL => 'Perpetual (Double)',
    N_SIZE_SINGLE => 'Fixed N Size (Single)',
    N_SIZE_DOUBLE => 'Fixed N Size (Double)',
    PILOT => 'Pilot'
  }.freeze
  NON_PERPETUAL = [N_SIZE_SINGLE, N_SIZE_DOUBLE, PILOT]
  SINGLE_SCREENINGS = [SINGLE_PERPETUAL, N_SIZE_SINGLE]
  DOUBLE_SCREENINGS = [DOUBLE_PERPETUAL, N_SIZE_DOUBLE]
  ALL_SCREENINGS = [PILOT]

  validates_presence_of :fulltext_screening_type

  belongs_to :project
  has_many :fulltext_screenings_users
  has_many :users, through: :fulltext_screenings_users

  has_many :fulltext_screenings_reasons
  has_many :reasons, through: :fulltext_screenings_reasons
  has_many :fulltext_screenings_tags
  has_many :tags, through: :fulltext_screenings_tags

  has_many :fulltext_screening_results, dependent: :destroy, inverse_of: :fulltext_screening

  def single_screening?
    SINGLE_SCREENINGS.include?(fulltext_screening_type)
  end

  def double_screening?
    DOUBLE_SCREENINGS.include?(fulltext_screening_type)
  end

  def all_screenings?
    ALL_SCREENINGS.include?(fulltext_screening_type)
  end

  def reasons_object
    fulltext_screenings_reasons = FulltextScreeningsReason.where(fulltext_screening: self).order(:position).includes(:reason)
    fulltext_screenings_reasons.map do |fulltext_screenings_reason|
      {
        id: fulltext_screenings_reason.id,
        reason_id: fulltext_screenings_reason.reason_id,
        name: fulltext_screenings_reason.reason.name,
        position: fulltext_screenings_reason.position,
        selected: false
      }
    end
  end

  def tags_object
    fulltext_screenings_tags = FulltextScreeningsTag.where(fulltext_screening: self).order(:position).includes(:tag)
    fulltext_screenings_tags.map do |fulltext_screenings_tag|
      {
        id: fulltext_screenings_tag.id,
        tag_id: fulltext_screenings_tag.tag_id,
        name: fulltext_screenings_tag.tag.name,
        position: fulltext_screenings_tag.position,
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
