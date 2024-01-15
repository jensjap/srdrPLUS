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
    @rooms[:citation_rooms] = []
    # Citation
    # .joins(citations_projects: { project: { projects_users: :user } })
    # .where(citations_projects: { project: { projects_users: { user: } } })
    # .distinct.map do |citation|
    #   "citation-#{citation.id}"
    # end
    @rooms[:screening_rooms] =
      AbstractScreening
      .where(project: user.projects)
      .distinct
      .map do |abstract_screening|
        "abstract_screening-#{abstract_screening.id}"
      end
    @rooms[:screening_rooms] +=
      FulltextScreening
      .where(project: user.projects)
      .distinct
      .map do |fulltext_screening|
        "fulltext_screening-#{fulltext_screening.id}"
      end
    @rooms
  end
end
