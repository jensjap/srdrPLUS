class MessageType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :messages, dependent: :destroy, inverse_of: :message_type
end
