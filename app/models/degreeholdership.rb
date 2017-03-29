class Degreeholdership < ApplicationRecord
  has_paper_trail

  belongs_to :profile
  belongs_to :degree

  validates :profile_id, presence: true
  validates :degree_id, presence: true
end
