class Titleship < ApplicationRecord
  belongs_to :profile
  belongs_to :title

  validates :profile_id, presence: true
  validates :title_id, presence: true

  has_paper_trail
  acts_as_paranoid
end
