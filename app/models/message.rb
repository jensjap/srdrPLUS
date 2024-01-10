class Message < ApplicationRecord
  belongs_to :message, optional: true
  belongs_to :user

  has_one :message_read, dependent: :destroy

  after_create :broadcast_message

  private

  def broadcast_message
    ActionCable.server.broadcast("chat_#{room}", { room:, user_id:, handle: user.handle, text:, created_at: })
  end
end
