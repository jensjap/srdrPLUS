class MessageType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :frequency, inverse_of: :message_types

  has_many :messages, dependent: :destroy, inverse_of: :message_type

  validates :frequency, presence: true
end
