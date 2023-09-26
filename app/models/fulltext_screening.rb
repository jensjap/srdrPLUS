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
#  hide_author             :boolean          default(FALSE), not null
#  hide_journal            :boolean          default(FALSE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class FulltextScreening < ApplicationRecord
  include ScreeningModule

  validates_presence_of :fulltext_screening_type

  belongs_to :project
  has_many :fulltext_screenings_users
  has_many :users, through: :fulltext_screenings_users

  has_many :fulltext_screenings_reasons
  has_many :reasons, through: :fulltext_screenings_reasons
  has_many :fulltext_screenings_tags
  has_many :tags, through: :fulltext_screenings_tags

  has_many :fulltext_screening_results, dependent: :destroy, inverse_of: :fulltext_screening

  def screening_type
    fulltext_screening_type
  end
end
