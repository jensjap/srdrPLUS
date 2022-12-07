# == Schema Information
#
# Table name: authors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Author < ApplicationRecord
  include SharedQueryableMethods

  after_commit :reindex_citations_projects

  has_many :authors_citations, dependent: :destroy
  has_many :citations, through: :authors_citations
  has_many :citations_projects, through: :citations

  def initials
    *rest, last = name.split
    (rest.map { |e| e[0] } << last).reverse!.map(&:capitalize).join(' ')
  end

  def reindex_citations_projects
    citations_projects.each(&:reindex)
  end
end
