class Organization < ApplicationRecord
  include SharedMethods

  acts_as_paranoid
  has_paper_trail

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :profiles, dependent: :nullify, inverse_of: :profile
end

