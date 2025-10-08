class MessagesController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.json do
        if (room = Room.find_by(id: params[:room_id]))
          authorize(room, policy_class: MessagePolicy)
          @messages = get_messages(room)
        elsif (help_key = params[:help_key])
          @messages = Message.where(help_key:).includes(:project, user: :profile).order(id: :desc)
          @messages.map(&:project).uniq.each do |project|
            authorize(project, policy_class: MessagePolicy)
          end
        elsif (project = Project.find_by(id: params[:project_id]))
          authorize(project, policy_class: MessagePolicy)
          @messages = Message.where(project:).includes(:project, user: :profile).order(id: :desc)
          @messages.map(&:project).uniq.each do |pro|
            authorize(pro, policy_class: MessagePolicy)
          end
        else
          @current_user = current_user
          @all_users =
            ProjectsUser
            .joins(:project)
            .where(projects: current_user.projects)
            .includes(user: :profile)
            .map { |pu| { username: pu.user.username, user_id: pu.user_id } }
            .uniq
          rooms = ChatChannelService.generate_rooms(current_user)
          @chat_rooms = rooms[:chat_rooms]
          @messages = get_messages(@chat_rooms)
        end
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        message = Message.find(params[:id])
        authorize(message)

        message.update(message_params)
        render json: {}, status: 200
      end
    end
  end

  def create
    respond_to do |format|
      format.json do
        message = Message.new(message_params)
        message.user = current_user
        authorize(message)

        message.save!
        message.broadcast_message
        render json: message, status: 200
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        message = Message.find(params[:id])
        authorize(message)

        message.destroy
        render json: {}, status: 200
      end
    end
  end

  private

  def message_params
    params
      .require(:message)
      .permit(:room_id,
              :text,
              :pinned,
              :message_id,
              :help_key,
              :project_id,
              :extraction_id)
  end

  def get_messages(rooms)
    messages = {}
    Message
      .where(room: rooms)
      .includes(
        :room,
        {
          user: :profile,
          message_unreads: :user,
          messages: [:room, { user: :profile, message_unreads: :user }]
        }
      )
      .order(created_at: :desc)
      .each do |message|
        message_unread =
          message.message_unreads.find { |mu| mu.user == current_user }
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
          messages:
            message.messages.map do |mmessage|
              mmessage_unread =
                mmessage.message_unreads.find { |mmu| mmu.user == current_user }
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
