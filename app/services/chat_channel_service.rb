class ChatChannelService
  def self.generate_rooms(user)
    @rooms = {}
    @rooms[:chat_rooms] = user.rooms
    @rooms
  end
end
