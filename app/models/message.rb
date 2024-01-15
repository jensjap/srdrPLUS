class Message < ApplicationRecord
  belongs_to :message, optional: true
  belongs_to :user

  has_one :message_read, dependent: :destroy

  after_create :broadcast_message

  private

  def broadcast_message
    type, id = room.split('-')
    online_user_ids = ActionCable.server.connections.map(&:current_user).map(&:id)
    broadcast_users =
      case type
      when 'project'
        User
      .joins(projects_users: :project)
      .where(projects: { id: })
      .includes(:profile)
      .where(id: online_user_ids)
      .distinct
      when 'user'
        User
      .where(id: id
        .split('/'))
      .where(id: online_user_ids)
      .distinct
      when 'citation'
        []
      #   User
      # .joins(projects_users: { project: { citations_projects: :citation } })
      # .where(citations: { id: })
      # .includes(:profile)
      # .where(id: online_user_ids)
      # .distinct
      when 'abstract_screening'
        User
      .joins(projects_users: { project: { abstract_screenings: { id: } } })
      .includes(:profile)
      .where(id: online_user_ids)
      .distinct
      when 'fulltext_screening'
        User
      .joins(projects_users: { project: { fulltext_screenings: { id: } } })
      .includes(:profile)
      .where(id: online_user_ids)
      .distinct
      else
        []
      end
    broadcast_users.each do |broadcast_user|
      ActionCable.server.broadcast(
        "user_#{broadcast_user.id}",
        { room:, user_id:, handle: user.handle, text:, created_at: }
      )
    end
  end
end
