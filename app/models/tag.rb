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
  before_destroy :really_destroy_children!
  def really_destroy_children!
    taggings.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  has_many :abstract_screening_results_tags
  has_many :abstract_screening_results, through: :abstract_screening_results_tags
  has_many :fulltext_screening_results_tags
  has_many :fulltext_screening_results, through: :fulltext_screening_results_tags

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
end
