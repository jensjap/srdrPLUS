class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  has_many :titleships
  has_many :titles, through: :titleships, dependent: :destroy

  has_paper_trail
  acts_as_paranoid
end
