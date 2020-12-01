# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class Author < ApplicationRecord
  include SharedQueryableMethods
  has_many :authors_citations, dependent: :destroy
  has_many :citations, through: :authors_citations

  acts_as_paranoid

  def initials
    *rest, last = self.name.split
    (rest.map{ |e| e[0] } << last).reverse!.map(&:capitalize).join(' ')
  end
end
