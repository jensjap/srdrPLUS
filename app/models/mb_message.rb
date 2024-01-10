class MbMessage < ApplicationRecord
  belongs_to :message_board
  belongs_to :mb_message, optional: true

  has_one :mb_read, dependent: :destroy

  after_create :broadcast_message

  private

  def broadcast_message
    ActionCable.server.broadcast("chat_#{message_board.key}", { text: })
  end
end
