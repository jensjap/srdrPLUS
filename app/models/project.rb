class Project < ApplicationRecord
  include SharedMethods

  acts_as_paranoid
  has_paper_trail

  paginates_per 8
end
