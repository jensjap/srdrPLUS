# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organization < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    Suggestion.with_deleted.where(suggestable_type: self.class, suggestable_id: id).each(&:really_destroy!)
  end

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :profiles, dependent: :nullify, inverse_of: :organization

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
