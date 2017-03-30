class Degreeholdership < ApplicationRecord
  has_paper_trail

  belongs_to :profile, inverse_of: :degreeholderships
  belongs_to :degree, inverse_of: :degreeholderships

  validates :profile_id, presence: true
  validates :degree_id, presence: true
end
