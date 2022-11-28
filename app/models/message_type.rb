# == Schema Information
#
# Table name: message_types
#
#  id           :integer          not null, primary key
#  name         :string(255)
#  frequency_id :integer
#  deleted_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MessageType < ApplicationRecord
  acts_as_paranoid
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    messages.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  belongs_to :frequency, inverse_of: :message_types

  has_many :messages, dependent: :destroy, inverse_of: :message_type

  validates :frequency, presence: true
end
