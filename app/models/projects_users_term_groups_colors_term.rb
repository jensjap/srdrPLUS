class ProjectsUsersTermGroupsColorsTerm < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  #validate :terms_should_be_unique_to_projects_user

  belongs_to :projects_users_term_groups_color
  belongs_to :term

  has_one :projects_user

  private
    def terms_should_be_unique_to_projects_user
      if projects_users_term_groups_color.projects_user.terms.where(id: term.id).present?
        errors.add(:term, "has to be unique for projects_user")
      end
    end
end
