# == Schema Information
#
# Table name: degrees
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Degree < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    degrees_profiles.with_deleted.each do |child|
      child.really_destroy!
    end
    profiles.with_deleted.each do |child|
      child.really_destroy!
    end
    Suggestion.with_deleted.where(suggestable_type: self.class, suggestable_id: id).each(&:really_destroy!)
  end

  after_create :record_suggestor

  # before_destroy :raise_error

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :degrees_profiles, dependent: :destroy, inverse_of: :degree
  has_many :profiles, through: :degrees_profiles, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  private

  # You should NEVER delete a Degree.
  def raise_error
    raise 'You should NEVER delete a Degree.'
  end
end
