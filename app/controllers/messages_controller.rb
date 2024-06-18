class MessagesController < ApplicationController
  def index
    # TODO: authorize
    respond_to do |format|
      format.json do
        if params[:room_id]
          @messages = get_messages(Room.find_by(id: params[:room_id]))
        else
          @current_user = current_user
          @all_users = ProjectsUser.joins(:project).where(projects: current_user.projects).includes(user: :profile).map do |pu|
            { username: pu.user.username, user_id: pu.user_id }
          end.uniq
          rooms = ChatChannelService.generate_rooms(current_user)
          @project_rooms = rooms[:project_rooms]
          @chat_rooms = rooms[:chat_rooms]
          @messages = get_messages(@project_rooms | @chat_rooms)
        end
      end
    end
  end

  def update
    # TODO: authorize
    respond_to do |format|
      format.json do
        message = Message.find(params[:id])
        message.update(strong_params)
        render json: {}, status: 200
      end
    end
  end

  def create
    # TODO: authorize the room
    respond_to do |format|
      format.json do
        message = Message.new(strong_params)
        message.user = current_user
        message.save!
        message.broadcast_message
        render json: {}, status: 200
      end
    end
  end

  def destroy
    # TODO: authorize
    respond_to do |format|
      format.json do
        message = Message.find(params[:id])
        message.destroy
        render json: {}, status: 200
      end
    end
  end

  private

  def strong_params
    params.require(:message).permit(:room_id, :text, :pinned, :message_id)
  end

  def get_messages(rooms)
    messages = {}
    Message
      .where(room: rooms)
      .includes(:room, { user: :profile, message_unreads: :user,
                         messages: [:room, { user: :profile, message_unreads: :user }] })
      .order(created_at: :desc)
      .each do |message|
      message_unread = message.message_unreads.find do |mu|
        mu.user == current_user
      end
      messages[message.room.id] ||= []
      messages[message.room.id] << {
        id: message.id,
        room: message.room,
        user_id: message.user_id,
        handle: message.user.handle,
        text: message.text,
        created_at: message.created_at,
        read: message_unread.blank?,
        message_unread_id: message_unread&.id,
        pinned: message.pinned,
        message_id: message.message_id,
        messages: message.messages.map do |mmessage|
                    mmessage_unread = mmessage.message_unreads.find do |mmu|
                      mmu.user == current_user
                    end
                    {
                      id: mmessage.id,
                      room: mmessage.room,
                      user_id: mmessage.user_id,
                      handle: mmessage.user.handle,
                      text: mmessage.text,
                      created_at: mmessage.created_at,
                      read: mmessage_unread.blank?,
                      message_unread_id: mmessage_unread&.id,
                      pinned: mmessage.pinned,
                      message_id: mmessage.message_id
                    }
                  end
      }
    end
    messages
  end
end
