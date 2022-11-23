# == Schema Information
#
# Table name: authors_citations
#
#  citation_id :integer          not null
#  author_id   :integer          not null
#  id          :bigint           not null, primary key
#  deleted_at  :datetime
#

class AuthorsCitation < ApplicationRecord
  include SharedOrderableMethods

  before_validation -> { set_ordering_scoped_by(:citation_id) }, on: :create

  belongs_to :author
  belongs_to :citation
  has_one :ordering, as: :orderable, dependent: :destroy

  delegate :position, to: :ordering

  accepts_nested_attributes_for :author
  accepts_nested_attributes_for :ordering

  acts_as_paranoid
  before_destroy :really_destroy_children!
  def really_destroy_children!
    Ordering.with_deleted.where(orderable_type: self.class, orderable_id: id).each(&:really_destroy!)
  end
end
