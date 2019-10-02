class Author < ApplicationRecord
  include SharedQueryableMethods
  has_many :authors_citations, dependent: :destroy
  has_many :citations, through: :authors_citations

  acts_as_paranoid
  has_paper_trail

  def initials
    *rest, last = self.name.split
    (rest.map{ |e| e[0] } << last).reverse!.map(&:capitalize).join(' ')
  end
end
