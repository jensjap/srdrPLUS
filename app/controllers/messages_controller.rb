class MessagesController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @current_user = current_user
        project_rooms = current_user.projects.map { |p| "project-#{p.id}" }
        user_rooms = User
                     .joins(projects_users: :user)
                     .where(projects_users: { project: current_user.projects })
                     .distinct
                     .map do |user|
          "user-#{user.id}"
        end
        extraction_rooms = Extraction
                           .joins(projects_users_role: { projects_user: :user })
                           .where(projects_users_roles: { projects_users: { users: current_user } }).map do |extraction|
          "extraction-#{extraction.id}"
        end
        screening_rooms = AbstractScreening.where(project: current_user.projects).map do |abstract_screening|
          "abstract_screening-#{abstract_screening.id}"
        end
        screening_rooms += FulltextScreening.where(project: current_user.projects).map do |fulltext_screening|
          "fulltext_screening-#{fulltext_screening.id}"
        end
        @project_rooms = project_rooms
        @user_rooms = user_rooms
        @extraction_rooms = extraction_rooms
        @screening_rooms = screening_rooms
        @messages = {}
        Message.where(room: @project_rooms).each do |mb_message|
          @messages[mb_message.room] ||= []
          @messages[mb_message.room] << mb_message
        end
      end
    end
  end
end
