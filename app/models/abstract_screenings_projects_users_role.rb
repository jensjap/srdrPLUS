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
  delegate :user, to: :projects_users_role

  has_many :word_weights, dependent: :destroy, inverse_of: :abstract_screenings_projects_users_role
  has_many :abstract_screenings_projects_users_role_tags, dependent: :destroy,
                                                          inverse_of: :abstract_screenings_projects_users_role
  has_many :abstract_screenings_projects_users_role_reasons, dependent: :destroy,
                                                             inverse_of: :abstract_screenings_projects_users_role
  has_many :reasons, through: :abstract_screenings_projects_users_role_reasons
  has_many :tags, through: :abstract_screenings_projects_users_role_tags
  has_many :abstract_screening_results, dependent: :destroy, inverse_of: :abstract_screenings_projects_users_role

  def process_reasons(asr, predefined_reasons, custom_reasons)
    asr.reasons.destroy_all
    predefined_reasons.merge(custom_reasons).each do |reason, included|
      next unless included

      asr.reasons << Reason.find_or_create_by(name: reason)
    end
    self.reasons = custom_reasons.keys.map { |reason| Reason.find_or_create_by(name: reason) }
  end

  def process_tags(asr, predefined_tags, custom_tags)
    asr.tags.destroy_all
    predefined_tags.merge(custom_tags).each do |tag, included|
      next unless included

      asr.tags << Tag.find_or_create_by(name: tag)
    end
    self.tags = custom_tags.keys.map { |tag| Tag.find_or_create_by(name: tag) }
  end

  def reasons_object
    reasons.each_with_object({}) do |reason, hash|
      hash[reason.name] = false
      hash
    end
  end

  def tags_object
    tags.each_with_object({}) do |tag, hash|
      hash[tag.name] = false
      hash
    end
  end

  # AbstractScreeningsProjectsUsersRole is not always present since we allow anyone
  # to start screening by default (see AbstractScreeningPolicy).
  # In case ASPUR does not exist we initialize it here.
  def self.find_aspur(user, abstract_screening)
    #AbstractScreeningsProjectsUsersRole
    #  .joins(projects_users_role: { projects_user: :user })
    #  .where(abstract_screening:, projects_users_role: { projects_users: { user: } })
    #  .first
    AbstractScreeningsProjectsUsersRole
      .find_or_initialize_by(
        abstract_screening:,
        projects_users_role: ProjectsUsersRole.where(
          projects_user: ProjectsUser.find_by(
            project_id: abstract_screening.project.id,
            user:
          )
        ).first
      )
  end

  def word_weights_object
    word_weights.each_with_object({}) do |ww, hash|
      hash[ww.word] = { weight: ww.weight, id: ww.id }
      hash
    end
  end
end