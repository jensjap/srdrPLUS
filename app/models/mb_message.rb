class MbMessage < ApplicationRecord
  belongs_to :message_board
  belongs_to :mb_message, optional: true

  has_one :mb_read, dependent: :destroy
end
