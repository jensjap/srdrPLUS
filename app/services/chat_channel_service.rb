class ChatChannelService
  def self.generate_rooms(user)
    @rooms = {}
    Project
      .left_joins(:room)
      .joins(projects_users: :user)
      .where(users: user)
      .where(rooms: { id: nil })
      .each do |project|
      project.create_room(name: project.name)
    end
    Room
      .joins(:project)
      .left_joins(:memberships)
      .where(rooms: { project: user.projects })
      .includes(:users, project: :users)
      .each do |room|
      room.project.users.each do |uuser|
        room.users << uuser unless room.user_ids.include?(uuser.id)
      end
    end
    @rooms[:project_rooms] = user.rooms.where.not(project_id: nil)
    @rooms[:chat_rooms] = user.rooms.where(project_id: nil)
    @rooms
  end
end
