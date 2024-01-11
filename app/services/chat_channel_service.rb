class ChatChannelService
  def self.generate_rooms(user)
    @rooms = {}

    @rooms[:project_rooms] = user.projects.map { |p| "project-#{p.id}" }
    @rooms[:user_rooms] =
      User
      .joins(projects_users: :user)
      .where(projects_users: { project: user.projects })
      .distinct
      .map do |uuser|
        user_ids = [user.id, uuser.id].sort
        "user-#{user_ids.join('/')}"
      end
    @rooms[:extraction_rooms] = Extraction
                                .joins(projects_users_role: { projects_user: :user })
                                .where(projects_users_roles: { projects_users: { users: user } }).map do |extraction|
      "extraction-#{extraction.id}"
    end
    @rooms[:screening_rooms] = AbstractScreening.where(project: user.projects).map do |abstract_screening|
      "abstract_screening-#{abstract_screening.id}"
    end
    @rooms[:screening_rooms] += FulltextScreening.where(project: user.projects).map do |fulltext_screening|
      "fulltext_screening-#{fulltext_screening.id}"
    end
    @rooms
  end
end
