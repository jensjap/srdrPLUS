# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class Tag < ApplicationRecord
  acts_as_paranoid

  after_commit :reindex_citations, :reindex_abstract_screening_results

  has_many :abstract_screening_results_tags
  has_many :abstract_screening_results, through: :abstract_screening_results_tags
  has_many :citations, through: :abstract_screening_results

  include SharedQueryableMethods

  has_many :taggings

  scope :by_project_lead, lambda { |project|
                            joins(:taggings).where(taggings: { projects_users_role_id: project.projects_users_roles.where(role: Role.find_by(name: 'Leader')) }).order(:name).distinct
                          }

  scope :by_user, lambda { |user|
                    joins(:taggings).where(taggings: { projects_users_role_id: user.projects_users_roles }).order(:name).distinct
                  }

  scope :by_projects_user, lambda { |projects_user|
                             joins(:taggings).where(taggings: { projects_users_role_id: projects_user.projects_users_roles }).order(:name).distinct
                           }

  def reindex_citations
    citations.each(&:reindex)
  end

  def reindex_abstract_screening_results
    abstract_screening_results.each(&:reindex)
  end
end
