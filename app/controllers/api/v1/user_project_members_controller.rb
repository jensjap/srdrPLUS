class Api::V1::UserProjectMembersController < Api::V1::BaseController
  before_action :set_current_user_projects

  def index
    # Get all users from projects that the current user is part of
    users = User.includes(:projects_users, :profile)
                .where(projects_users: { project_id: @user_project_ids })
                .where.not(id: current_user.id) # Exclude current user
                .distinct

    # Filter by search query if provided
    if params[:q].present?
      query = params[:q].downcase
      users = users.where('LOWER(users.email) LIKE ? OR LOWER(profiles.username) LIKE ?',
                          "%#{query}%", "%#{query}%")
    end

    users = users.limit(50)

    formatted_users = users.map do |user|
      {
        id: user.id,
        email: user.email,
        username: user.profile&.username || user.email.split('@').first,
        display_text: "@#{user.email}",
        profile_url: "/users/#{user.id}" # or wherever user profiles are located
      }
    end

    respond_with formatted_users
  end

  private

  def set_current_user_projects
    @user_project_ids = current_user.projects.pluck(:id)
  end
end
