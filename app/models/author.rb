class Author < ApplicationRecord
  include SharedQueryableMethods
  belongs_to :citation, optional: true

  acts_as_paranoid
  has_paper_trail
end
