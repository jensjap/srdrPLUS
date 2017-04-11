class Message < ApplicationRecord
  include SharedMethods

  acts_as_paranoid
  has_paper_trail

  belongs_to :message_type, inverse_of: :messages

  has_many :dispatches, as: :dispatchable, dependent: :destroy
end
