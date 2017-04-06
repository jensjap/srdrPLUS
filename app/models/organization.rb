class Organization < ApplicationRecord
  include SharedMethods

  after_create :record_suggestor

  acts_as_paranoid
  has_paper_trail

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :profiles, dependent: :nullify, inverse_of: :profile

  validates :name, uniqueness: true

  private

  def record_suggestor
    self.create_suggestion(user: User.current) if User.current
  end
end

