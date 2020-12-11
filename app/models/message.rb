# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  message_type_id :integer
#  name            :string(255)
#  description     :text(65535)
#  start_at        :datetime
#  end_at          :datetime
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Message < ApplicationRecord
  include SharedDispatchableMethods
  include SharedQueryableMethods

  acts_as_paranoid

  belongs_to :message_type, inverse_of: :messages

  has_one :frequency, through: :message_type

  has_many :dispatches, as: :dispatchable, dependent: :destroy

  validates :message_type, presence: true
end
