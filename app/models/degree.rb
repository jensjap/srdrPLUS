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
  has_paper_trail

  after_create :record_suggestor

  before_destroy :raise_error

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

