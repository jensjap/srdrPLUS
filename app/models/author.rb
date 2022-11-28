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

  after_commit :reindex_citations_projects

  has_many :authors_citations, dependent: :destroy
  has_many :citations, through: :authors_citations
  has_many :citations_projects, through: :citations

  acts_as_paranoid
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    authors_citations.with_deleted.each do |child|
      child.really_destroy!
    end
    citations.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  def initials
    *rest, last = name.split
    (rest.map { |e| e[0] } << last).reverse!.map(&:capitalize).join(' ')
  end

  def reindex_citations_projects
    citations_projects.each(&:reindex)
  end
end
