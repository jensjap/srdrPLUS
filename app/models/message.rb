class Message < ApplicationRecord
  include SharedDispatchableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  belongs_to :message_type, inverse_of: :messages

  has_one :frequency, through: :message_type

  has_many :dispatches, as: :dispatchable, dependent: :destroy
end
