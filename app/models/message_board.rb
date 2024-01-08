class MessageBoard < ApplicationRecord
  has_many :mb_messages, dependent: :destroy
end
