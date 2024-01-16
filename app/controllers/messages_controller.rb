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
        Message.where(room: @project_rooms).includes(:message_unreads,
                                                     { user: :profile }).order(created_at: :desc).each do |message|
          @messages[message.room] ||= []
          @messages[message.room] << {
            room: message.room,
            user_id: message.user_id,
            handle: message.user.handle,
            text: message.text,
            created_at: message.created_at,
            read: message.message_unreads.none? { |message_unread| message_unread.user == current_user }
          }
        end
      end
    end
  end

  def create
    # TODO: authorize the room
    respond_to do |format|
      format.json do
        message = Message.new(strong_params)
        message.user = current_user
        render json: {}, status: message.save ? 200 : 403
      end
    end
  end

  private

  def strong_params
    params.require(:message).permit(:room, :text)
  end
end
