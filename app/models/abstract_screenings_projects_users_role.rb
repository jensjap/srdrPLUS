# == Schema Information
#
# Table name: abstract_screenings_projects_users_roles
#
#  id                     :bigint           not null, primary key
#  abstract_screening_id  :bigint           not null
#  projects_users_role_id :bigint           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
class AbstractScreeningsProjectsUsersRole < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :projects_users_role
  has_many :word_weights, dependent: :destroy, inverse_of: :abstract_screenings_projects_users_role

  def self.find_aspur(user, abstract_screening)
    AbstractScreeningsProjectsUsersRole
      .joins(projects_users_role: { projects_user: :user })
      .where(abstract_screening:, projects_users_role: { projects_users: { user: } })
      .first
  end

  def word_weights_object
    word_weights.each_with_object({}) do |ww, hash|
      hash[ww.word] = ww.weight
      hash
    end
  end
end
