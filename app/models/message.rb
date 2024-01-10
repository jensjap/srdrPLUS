class Message < ApplicationRecord
  belongs_to :message, optional: true

  has_one :message_read, dependent: :destroy

  after_create :broadcast_message

  private

  def broadcast_message
    ActionCable.server.broadcast("chat_#{room}", { text: })
  end
end
