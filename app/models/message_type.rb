# == Schema Information
#
# Table name: message_types
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  frequency_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MessageType < ApplicationRecord
  belongs_to :frequency, inverse_of: :message_types

  has_many :messages, dependent: :destroy, inverse_of: :message_type

  validates :frequency, presence: true
end
