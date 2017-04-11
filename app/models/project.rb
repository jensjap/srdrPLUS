class Project < ApplicationRecord
  include SharedPublishableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  paginates_per 8

  has_many :publishings, as: :publishable, dependent: :destroy
  has_many :approvals, through: :publishings, dependent: :destroy
end
