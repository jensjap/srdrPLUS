class MessageBoardsController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @current_user = current_user
        project_keys = current_user.projects.map { |p| "project-#{p.id}" }
        user_keys = User
                    .joins(projects_users: :user)
                    .where(projects_users: { project: current_user.projects })
                    .distinct
                    .map do |user|
          "user-#{user.id}"
        end
        extraction_keys = Extraction
                          .joins(projects_users_role: { projects_user: :user })
                          .where(projects_users_roles: { projects_users: { users: current_user } }).map do |extraction|
          "extraction-#{extraction.id}"
        end
        screening_keys = AbstractScreening.where(project: current_user.projects).map do |abstract_screening|
          "abstract_screening-#{abstract_screening.id}"
        end
        screening_keys += FulltextScreening.where(project: current_user.projects).map do |fulltext_screening|
          "fulltext_screening-#{fulltext_screening.id}"
        end
        @projects_message_boards = MessageBoard.where(key: project_keys)
        @users_message_boards = MessageBoard.where(key: user_keys)
        @extractions_message_boards = MessageBoard.where(key: extraction_keys)
        @screenings_message_boards = MessageBoard.where(key: screening_keys)
      end
    end
  end
end
