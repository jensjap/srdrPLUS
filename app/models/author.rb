class Author < ApplicationRecord
  include SharedQueryableMethods
  has_and_belongs_to_many :citations

  acts_as_paranoid
  has_paper_trail
end
