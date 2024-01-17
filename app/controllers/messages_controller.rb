class MessagesController < ApplicationController
  def index
    respond_to do |format|
      format.json do
        @current_user = current_user
        rooms = ChatChannelService.generate_rooms(current_user)
        @project_rooms = rooms[:project_rooms]
        @user_rooms = rooms[:user_rooms]
        @citation_rooms = rooms[:citation_rooms]
        @screening_rooms = rooms[:screening_rooms]
        @messages = {}
        Message
          .where(room: @project_rooms)
          .includes({ user: :profile, message_unreads: :user })
          .order(created_at: :desc)
          .each do |message|
          message_unread = message.message_unreads.find do |mu|
            mu.user == current_user
          end
          @messages[message.room] ||= []
          @messages[message.room] << {
            id: message.id,
            room: message.room,
            user_id: message.user_id,
            handle: message.user.handle,
            text: message.text,
            created_at: message.created_at,
            read: message_unread.blank?,
            message_unread_id: message_unread&.id,
            pinned: message.pinned
          }
        end
      end
    end
  end

  def update
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

  private

  def strong_params
    params.require(:message).permit(:room, :text, :pinned)
  end
end
