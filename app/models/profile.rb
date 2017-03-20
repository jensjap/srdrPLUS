class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :organization
  belongs_to :title

  has_paper_trail
end
